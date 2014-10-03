function [sol,b,obj] = primal_svm(linear,Y,lambda,opt)
% [SOL, B] = PRIMAL_SVM(LINEAR,Y,LAMBDA,OPT)
% Solves the SVM optimization problem in the primal (with quatratic
%   penalization of the training errors).  
%
% If LINEAR is 1, a global variable X containing the training inputs
%   should be defined. X is an n x d matrix (n = number of points).
% If LINEAR is 0, a global variable K (the n x n kernel matrix) should be defined.  
% Y is the target vector (+1 or -1, length n). 
% LAMBDA is the regularization parameter ( = 1/C)
%
% IF LINEAR is 0, SOL is the expansion of the solution (vector beta of length n).
% IF LINEAR is 1, SOL is the hyperplane w (vector of length d).
% B is the bias
% The outputs on the training points are either K*SOL+B or X*SOL+B
% OBJ is the objective function value
% 
% OPT is a structure containing the options (in brackets default values):
%   cg: Do not use Newton, but nonlinear conjugate gradients [0]
%   lin_cg: Compute the Newton step with linear CG 
%           [0 unless solving sparse linear SVM]
%   iter_max_Newton: Maximum number of Newton steps [20]
%   prec: Stopping criterion
%   cg_prec and cg_it: stopping criteria for the linear CG.
 
% Copyright Olivier Chapelle, olivier.chapelle@tuebingen.mpg.de
% Last modified 25/08/2006  
  
  if nargin < 4       % Assign the options to their default values
    opt = [];
  end;
  if ~isfield(opt,'cg'),                opt.cg = 0;                        end;
  if ~isfield(opt,'lin_cg'),            opt.lin_cg = 0;                    end;  
  if ~isfield(opt,'iter_max_Newton'),   opt.iter_max_Newton = 20;          end;  
  if ~isfield(opt,'prec'),              opt.prec = 1e-6;                   end;  
  if ~isfield(opt,'cg_prec'),           opt.cg_prec = 1e-4;                end;  
  if ~isfield(opt,'cg_it'),             opt.cg_it = 20;                    end;  
  
  
  % Call the right function depending on problem type and CG / Newton 
  % Also check that X / K exists and that the dimension of Y is correct
  if  linear 
    global X;
    if isempty(X), error('Global variable X undefined'); end;
    [n,d] = size(X);
    if issparse(X), opt.lin_cg = 1; end;
    if size(Y,1)~=n, error('Dimension error'); end;
    if ~opt.cg
      [sol,obj] = primal_svm_linear   (Y,lambda,opt);
    else
      [sol,obj] = primal_svm_linear_cg(Y,lambda,opt);
    end;
    
  else
    global K;
    if isempty(K), error('Global variable K undefined'); end;
    n = size(Y,1);
    if any(size(K)~=n), error('Dimension error'); end;
    if ~opt.cg 
      [sol,obj] = primal_svm_nonlinear   (Y,lambda,opt); 
    else
      [sol,obj] = primal_svm_nonlinear_cg(Y,lambda,opt); 
    end;
    
  end;
  % The last component of the solution is the bias b.
  b = sol(end);
  sol = sol(1:end-1);
  fprintf('\n');
  
  
function  [w,obj] = primal_svm_linear(Y,lambda,opt) 
% -------------------------------
% Train a linear SVM using Newton 
% -------------------------------
  global X;
  [n,d] = size(X);
    
  w = zeros(d+1,1); % The last component of w is b.
  iter = 0;
  out = ones(n,1); % Vector containing 1-Y.*(X*w)
  
  while 1
    iter = iter + 1;
    if iter > opt.iter_max_Newton;
      warning(sprintf(['Maximum number of Newton steps reached.' ...
                       'Try larger lambda']));
      break;
    end;
    
    [obj, grad, sv] = obj_fun_linear(w,Y,lambda,out);      
    
    % Compute the Newton direction either exactly or by linear CG
    if opt.lin_cg
      % Advantage of linear CG when using sparse input: the Hessian is never
      %   computed explicitly.
      [step, foo, relres] = minres(@hess_vect_mult, -grad,...
                                   opt.cg_prec,opt.cg_it,[],[],[],sv,lambda);
    else
      Xsv = X(sv,:);
      hess = lambda*diag([ones(d,1); 0]) + ...   % Hessian
             [[Xsv'*Xsv sum(Xsv,1)']; [sum(Xsv) length(sv)]];
      step  = - hess \ grad;   % Newton direction
    end;
    
    % Do an exact line search
    [t,out] = line_search_linear(w,step,out,Y,lambda);
    
    w = w + t*step;
    fprintf(['Iter = %d, Obj = %f, Nb of sv = %d, Newton decr = %.3f, ' ...
             'Line search = %.3f'],iter,obj,length(sv),-step'*grad/2,t);
    if opt.lin_cg
        fprintf(', Lin CG acc = %.4f     \n',relres);
    else
        fprintf('      \n');
    end;
    
    if -step'*grad < opt.prec * obj  
      % Stop when the Newton decrement is small enough
      break;
    end;
  end;
 
function  [w, obj] = primal_svm_linear_cg(Y,lambda,opt)
% -----------------------------------------------------
% Train a linear SVM using nonlinear conjugate gradient 
% -----------------------------------------------------
  global X;
  [n,d] = size(X);
    
  w = zeros(d+1,1); % The last component of w is b.
  iter = 0;
  out = ones(n,1); % Vector containing 1-Y.*(X*w)
  go = [X'*Y; sum(Y)];  % -gradient at w=0 
  
  s = go; % The first search direction is given by the gradient
  while 1
    iter = iter + 1;
    if iter > opt.cg_it * min(n,d)
      warning(sprintf(['Maximum number of CG iterations reached. ' ...
                       'Try larger lambda']));
      break;
    end;
     
    % Do an exact line search
    [t,out] = line_search_linear(w,s,out,Y,lambda);
    w = w + t*s;
      
    % Compute the new gradient
    [obj, gn] = obj_fun_linear(w,Y,lambda,out); gn=-gn;
    fprintf('Iter = %d, Obj = %f, Norm of grad = %.3f     \n',iter,obj,norm(gn));
      
    % Stop when the relative decrease in the objective function is small 
    if t*s'*go < opt.prec*obj, break; end;
    
    % Flecher-Reeves update. Change 0 in 1 for Polack-Ribiere
    be = (gn'*gn - 0*gn'*go) / (go'*go);
    s = be*s+gn;
    go = gn;
  end;
   
  
  
function [obj, grad, sv] = obj_fun_linear(w,Y,lambda,out)
  % Compute the objective function, its gradient and the set of support vectors
  % Out is supposed to contain 1-Y.*(X*w)
  global X
  out = max(0,out);
  w0 = w; w0(end) = 0;  % Do not penalize b
  obj = sum(out.^2)/2 + lambda*w0'*w0/2; % L2 penalization of the errors
  grad = lambda*w0 - [((out.*Y)'*X)'; sum(out.*Y)]; % Gradient
  sv = find(out>0);  
  
  
function y = hess_vect_mult(w,sv,lambda)
  % Compute the Hessian times a given vector x.
  % hess = lambda*diag([ones(d-1,1); 0]) + (X(sv,:)'*X(sv,:));
  global X
  y = lambda*w;
  y(end) = 0;
  z = (X*w(1:end-1)+w(end));  % Computing X(sv,:)*x takes more time in Matlab :-(
  zz = zeros(length(z),1);
  zz(sv)=z(sv);
  y = y + [(zz'*X)'; sum(zz)];
  
  
function [t,out] = line_search_linear(w,d,out,Y,lambda) 
  % From the current solution w, do a line search in the direction d by
  % 1D Newton minimization
  global X
  t = 0;
  % Precompute some dots products
  Xd = X*d(1:end-1)+d(end);
  wd = lambda * w(1:end-1)'*d(1:end-1);
  dd = lambda * d(1:end-1)'*d(1:end-1);
  while 1
    out2 = out - t*(Y.*Xd); % The new outputs after a step of length t
    sv = find(out2>0);
    g = wd + t*dd - (out2(sv).*Y(sv))'*Xd(sv); % The gradient (along the line)
    h = dd + Xd(sv)'*Xd(sv); % The second derivative (along the line)
    t = t - g/h; % Take the 1D Newton step. Note that if d was an exact Newton
                 % direction, t is 1 after the first iteration.
    if g^2/h < 1e-10, break; end;
%    fprintf('%f %f\n',t,g^2/h)
  end;
  out = out2;
  

  
function [beta,obj] = primal_svm_nonlinear(Y,lambda,opt)
% -----------------------------------
% Train a non-linear SVM using Newton
% -----------------------------------
  global K
  
  training = find(Y);   % The points with 0 are ignored.
  n = length(training); % The real number of training points
  if n>=1000  % Train a subset first
    perm = randperm(n);
    ind = training(perm(1:round(.75*n)));  % Take a random subset of size n/4
    Y2 = Y; Y2(ind) = 0;
    beta = primal_svm_nonlinear(Y2,lambda,opt);
    sv = find(beta(1:end-1)~=0);
    Kb = K(training,sv)*beta(sv);  % Kb will always contains K times the current beta
  else
    sv = training;
    beta = zeros(length(Y)+1,1); % The last component of beta is b.
    Kb = zeros(n,1);
  end;
  
  iter = 0;
  
  % If the set of support vectors has changed, we need to reiterate.
  while 1 
    old_sv = sv;
    % Computing the objective function
    out = 1 - Y(training) .* (Kb+beta(end)); 
    sv = training(out > 0);
    obj = (lambda*beta(training)'*Kb + sum(max(0,out).^2)) / 2;
    
    iter = iter + 1;
    % If the set of support vectors doesn't change, we can't improve anymore
    if (iter > 1) & isempty(setxor(sv,old_sv)), break; end;
    if iter > opt.iter_max_Newton
      warning(sprintf(['Maximum number of Newton steps reached. ' ...
                       'Try larger lambda']));
      break;
    end;      
    
    H = K(sv,sv) + lambda*eye(length(sv));
    cte_for_b = mean(diag(K));
    H(end+1,:) = cte_for_b;     % To take the bias into account
    H(:,end+1) = cte_for_b;     % The actual value of this constant does not matter.
    H(end,end) = 0;             % For numerical reasons, take it of the order of K.

    % Beta_new would be the new vevtor beta is the full Newton step is taken
    beta_new = zeros(length(Y)+1,1);
    if opt.lin_cg
      [beta_new([sv; end]), foo1, relres] = minres(H,[Y(sv);0],opt.cg_prec,opt.cg_it);
    else
      beta_new([sv; end]) = H\[Y(sv);0];
    end;
    beta_new(end) = beta_new(end) * cte_for_b;

    % Do line search, but with a preference for a full Newton step
    step = beta_new - beta; 
    [t, Kb] = line_search_nonlinear(step([training; end]),Kb,beta(end),Y,lambda,1);
    beta = beta + t*step; 

    fprintf('n = %d, iter = %d, obj = %f, nb of sv = %d, line srch = %.4f',...
            [n iter obj length(sv) t]);
    if opt.lin_cg
        fprintf(', Lin CG acc = %.4f     \n',relres);
    else
        fprintf('      \n');
    end;

  end;
  sol = beta;

function  [beta, obj] = primal_svm_nonlinear_cg(Y,lambda,opt)
% -----------------------------------------------------
% Train a linear SVM using nonlinear conjugate gradient 
% -----------------------------------------------------
  global K;
  n = length(K);
    
  beta = zeros(n+1,1); % The last component of beta is b.
  iter = 0;
  Kb = zeros(n,1); % Kb will always contains K times the current beta
  go = [Y; sum(Y)]; % go = -gradient at beta=0
  s = go; % Initial search direction
  Kgo = [K*Y; sum(Y)]; % We use the preconditioner [[K 0]; [0 1]]
  Ks = Kgo(1:end-1);   % Ks will always contain K*s(1:end-1)
  while 1
    iter = iter + 1;
    if iter > opt.cg_it * n
      warning(sprintf(['Maximum number of CG iterations reached. ' ...
                       'Try larger lambda']));
      break;
    end;
      
    % Do an exact line search
    [t,Kb] = line_search_nonlinear(s,Kb,beta(end),Y,lambda,0,Ks);
    beta = beta + t*s;
      
    % Compute new gradient and objective.
    % Note that the gradient is already "divided" by the preconditioner
    [obj, grad] = obj_fun_nonlinear(beta,Y,lambda,Kb); gn = -grad;
    fprintf('Iter = %d, Obj = %f, Norm grad = %f     \n',iter,obj,norm(gn));
    
    % Stop when the relative decrease in the objective function is small 
    if t*s'*Kgo < opt.prec*obj, break; end;
    
    Kgn = [K*gn(1:end-1); gn(end)];  % Multiply by the preconditioner 
                                     % -> Kgn is the real gradient

    % Flecher-Reeves update. Change 0 in 1 for Polack-Ribiere                             
    be = (Kgn'*gn - 0*Kgn'*go) / (Kgo'*go);
%    be = (gn'*gn - gn'*go) / (go'*go);
    s = be*s+gn;
    Ks = be*Ks + Kgn(1:end-1);

    go = gn;
    Kgo = Kgn;
   end;
   
  
function [t, Kb] = line_search_nonlinear(step,Kb,b,Y,lambda,fullstep,Ks)
 % Given the current solution (as given by Kb), do a line sesrch in 
 % direction step. First try to take a full step if fullstep = 1.
  global K;
  training = find(Y~=0);
  act = find(step(1:end-1));  % The set of points for which beta change
  if nargin<7
    Ks = K(training,training(act))*step(act);
  end; 
  Kss = step(act)'*Ks(act); % Precompute some dot products
  Kbs = step(act)'*Kb(act);
  t = 0;
  Y = Y(training);
  % Compute the objective function for t=1
  out = 1-Y.*(Kb+b+Ks+step(end)); sv = out>0;
  obj1 = (lambda*(2*Kbs+Kss)+sum(out(sv).^2))/2;
  while 1
    out = 1-Y.*(Kb+b+t*(Ks+step(end)));
    sv = out>0;
    % The objective function and the first derivative (along the line)
    obj = (lambda*(2*t*Kbs+t^2*Kss)+sum(out(sv).^2))/2;
    g = lambda * (Kbs+t*Kss) - (Ks(sv)'+step(end))*(Y(sv).*out(sv)); 
    if fullstep & (t==0) & (obj-obj1 > -0.2*g)
    % First check t=1: if it works, keep it -> sparser solution
     t = 1;
      break;
    end; 
    % The second derivative (along the line)
    h = lambda*Kss + norm(Ks(sv)+step(end))^2;
    % fprintf('%d %f %f %f\n',length(find(sv)),t,obj,g^2/h);
    % Take the 1D Newton step
    t = t - g/h;
    if g^2/h < 1e-10, break; end;

  end;
  Kb = Kb + t*Ks;

function [obj, grad] = obj_fun_nonlinear(beta,Y,lambda,Kb)
  global K;
  out = Kb+beta(end);
  sv = find(Y.*out < 1);
  % Objective function...
  obj = (lambda*beta(1:end-1)'*Kb + sum((1-Y(sv).*out(sv)).^2)) / 2;
  % ... and preconditioned gradient
  grad = [lambda*beta(1:end-1); sum(out(sv)-Y(sv))];
  grad(sv) = grad(sv) + (out(sv)-Y(sv));
  % To compute the real gradient, one would have to execute the following line
  % grad = [K*grad(1:end-1); grad(end)];
