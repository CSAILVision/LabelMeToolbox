function [beta,b,S,obj,te,time] = sparse_primal_svm(Y,Yt,ker,kerparam,C,opt)
% [BETA,B,S] = SPARSE_PRIMAL_SVM(Y,YT,KER,KERPARAM,C,OPT)
% Approximates the SVM solution by expanding it on a small set of basis functions  
%
% Y is the target vecor (+1 or -1, length n)
% YT is a test vector (length nt)
% KER is a function handle to a kernel function of the form
%    K = MY_KERNEL(IND1,IND2,KERPARAM) computing the kernel submatrix
%    between the points with indices IND1 and IND2. KERPARAM is an
%    additional argument containing for instance kernel
%    parameters. Indices are supposed to be between 1 and n+nt, an indice
%    larger than n corresponding to a test point.
% KERPARAM: see above
% C is the constant penalizing the training errors
% OPT is a structure containing the following optional fields
%    nb_cand (aka kappa): the number of candidates at each iteration
%    set_size (aka dmax): the final number of basis functions
%    maxiter: the maximum number of iterations for Newton
%    base_recomp: the solution is recomputed every base_recomp^p
%    verb: verbosity
%
% BETA is the vector of expansion coefficients
% B is the bias
% S contains the indices if the expansion (same size as BETA)
%  
% [BETA,B,S,OBJ,TE,TIME] = SPARSE_PRIMAL_SVM(Y,YT,KER,KERPARAM,C,OPT)
% OBJ,TE contains the objective function and the test error after
%    each retraining
% TIME contains the time spent between each retraining (it does not
%    include the time for computing the kernel test matrix).  

% Copyright Olivier Chapelle, olivier.chapelle@tuebingen.mpg.de
% Last modified Sep 11, 2006

  global K hess sv
  
  if nargin<6
    opt = []; 
  end;
  n = length(Y);
  
  % Set the parameters to their default value
  if ~isfield(opt,'nb_cand'),     opt.nb_cand     = 10;           end;
  if ~isfield(opt,'set_size'),    opt.set_size    = round(n/100); end;
  if ~isfield(opt,'maxiter'),     opt.maxiter     = 20;           end;
  if ~isfield(opt,'base_recomp'), opt.base_recomp = 2^0.25;       end; 
  if ~isfield(opt,'verb'),        opt.verb        = 1;            end; 

  % Memory allocation for K (size n times dmax) and Kt (size nt times dmax). 
  % The signed outputs are computed as K*[b; beta]. That's why the first
  % column is Y (and just 1 for Kt)
  K = zeros(n,opt.set_size+1); 
  K(:,1)=Y;
  Kt = zeros(length(Yt),opt.set_size+1);
  Kt(:,1)=1;
  
  % hess is the Cholesky decompostion of the Hessian
  hess = sqrt(C*n)*(1+1e-10);
  
  % At the beginning x (which contains [b; beta]) equal 0 and all points
  % are training errors. The set sv is set of points for which y_i f(x_i) < 1
  x = 0;
  sv = 1:n;
  
  S = [];
  te = [];
  time = [];
  obj = [];
  tic;
  
    
  while 1  % Loops until all the basis functions are selected

    if retrain(length(S),opt) % It's time to retrain ...
      d0 = size(hess);
      
      update_hess(S,Y,C,ker,kerparam); % First, compute the news columns
                                       % and K and update the Hessian and
                                       % its Cholesky decomposition
      [x,out,obj2] = train_subset(S,C,opt,x); % And then do a Newton optimization
      if obj2<0  % Newton didn't converge. Probably because the Hessian
                 % is not well conditioned. 1/C should be not much
                 % smaller than the diagonal elements of the kernel.
        mean_kernel = mean(feval(ker,1:size(K,1),[],kerparam));
        error(sprintf('Convergence problem. Try to take C of the oder of 10^%d.\n',...
                      ceil(log10(1/mean_kernel))));
      end;
      out = out(sv);
      obj = [obj obj2];
      time = [time toc];
      
      if ~isempty(Yt) % Compute the new test error
        nnt = length(S)-d0;
        if nnt>=0
          Kt(:,d0+1:d0+nnt+1) = feval(ker,n+[1:length(Yt)],S(end-nnt:end),kerparam);
        end;
        te = [te mean(Yt.*(Kt(:,1:length(x))*x)<0)];
        if opt.verb > 0, fprintf('  Test error = %.4f',te(end)); end;
      end;
      tic;
    end;
    
    if length(S)==opt.set_size % We're done !
      break;
    end;
    
    % Chooses a random subset for new candidates (exclude the points
    % which are already in the expansion)
    candidates = 1:n; 
    candidates(S) = [];
    candidates = candidates(randperm(length(candidates)));
    candidates = candidates(1:opt.nb_cand);
    
    [ind,x,out] = choose_next_point(candidates,S,x,out,Y,ker,kerparam,C,opt);
    S = [S candidates(ind)];
  end;

  beta = x(2:end);
  b = x(1);
  if opt.verb>0, fprintf('\n'); end;
    
function [x,out,obj] = train_subset(S,C,opt,x)
  global K hess sv
  persistent old_obj old_out x_old;
  
  if opt.verb>0, fprintf('\n'); end;
  iter = 0;
  d = length(hess);
  
  % We start from the old solution; the new components are either set to 0
  % or estimated (cf the end of the choose_next_point function), depending
  % on what gives the smallest objective value.
  old_sv = sv;
  out2 = K(:,1:d)*x;
  sv2 = find(out2'<1);
  obj2 = 0.5*((x(2:end,:).*K(S,1))'*K(S,2:d)*x(2:end,:) + ...
             C*sum((1-out2(sv2)).^2));
  if ~isempty(S) & (obj2 > old_obj)
    x_old = [x_old; zeros(length(x)-length(x_old),1)];
  else
    x_old = x;
    old_obj = obj2;
    sv = sv2;
    old_out = out2;
  end;

  while 1
    if iter > opt.maxiter
      obj = -1;
      return;
    end;
    iter = iter + 1;

    % The set of errors has changed (and so the Hessian). We update the
    % Cholesky decomposition of the Hessian
    for i=setdiff(sv,old_sv)
      hess = cholupdate(hess,sqrt(C)*K(i,1:d)','+');
    end;
    for i=setdiff(old_sv,sv)
      hess = cholupdate(hess,sqrt(C)*K(i,1:d)','-');
    end;
    old_sv = sv;
    
    % Take a few Newton step. By writing out the
    % equations, this simplifies to following equation:
    x = C*(hess \ (hess' \ sum(K(sv,1:d),1)'));
    step = x-x_old;                 % Newton step
    delta_out = K(:,1:d)*step;      % Change in the outputs.
 
    while 1  % Backtracking: if the Newton step is too long (resulting 
             % in an increase of the objective value), it is divided by 2.
      x = x_old + step;
      out = old_out + delta_out; 
      sv = find(out'<1); % Identify the errors
      % Compute the objective function 
      obj = 0.5*((x(2:end,:).*K(S,1))'*K(S,2:d)*x(2:end,:) + ...
                 C*sum((1-out(sv)).^2));
      if obj < old_obj, break; end;
      % The step is too long: divide by 2.
      step = step / 2;
      delta_out = delta_out / 2;
    end;
    
    x_old = x;
    old_obj = obj;
    old_out = out;
              
    if opt.verb>0
      fprintf(['\nNb basis = %d, iter Newton = %d, Obj = %.2f, ' ...
               'Nb errors = %d   '],length(hess)-1,iter,obj,length(sv));
    end;
    if isempty(setxor(old_sv,sv)) % No more changes -> stop
      break;
    end;
  end;
 
function update_hess(S,Y,C,ker,kerparam)
  global K hess sv
  
  d  = length(S);
  d0 = length(hess) - 1; 
  if d==d0, return; end;

  % Compute the new rows of K corresponding to the basis that have been added
  K(:,d0+2:d+1) = feval(ker,1:length(Y),S(end-(d-d0-1):end),kerparam) ...
      .* repmat(Y,1,d-d0);
  
  h = [zeros(1,d-d0); K(S,d0+2:d+1).*repmat(Y(S),1,d-d0)] + ...
      C * K(sv,1:d+1)' * K(sv,d0+2:d+1);

  % The new Hessian would be [[old_hessian h2]; [h2' h3]]
  h2 = h(d0+2:end,:);
  h2 = h2 + 1e-10*mean(diag(h2))*eye(size(h,2)); % Ridge is only for numerical reason
  h3 = hess' \ h(1:d0+1,:);
  h4 = chol(h2-h3'*h3);
  % New Cholesky decomposition of the augmented Hessian
  hess = [[hess h3]; [zeros(d-d0,d0+1) h4]];  
  
function [select,x,out] = choose_next_point(candidates,S,x,out,Y,ker,kerparam,C,opt)
  global K hess sv
  % When we choose the next basis function, we don't do any retraining
  % and assume that everyting is quadratic and that the other weights are fixed
  
  n = length(Y);
  K2 = feval(ker,sv,candidates,kerparam).*repmat(Y(sv),1,length(candidates));
  K3 = feval(ker,S, candidates,kerparam);
  Kd = feval(ker,candidates,[],kerparam);
  % If the point candidate(i) would be added as a basis function, the
  % first and second derivative with respect to its weight would be g(i) and h(i)
  h = Kd + C*sum(K2.^2,1)';
  g = K3'*x(2:end,:) + C*K2'*(out-1);
  score = g.^2./h; % Newton decrement
  [max_score, select] = max(score); % The larger the better
  if max_score<1e-8
    warning('No good basis function');
  end;
  x = [x; -g(select)/h(select)]; % Still assuming that the other weights
                                 % are fixed, the estimated weight of the
                                 % new basis function is g/h 
  
  out = out + K2(:,select)*x(end); % Update the outputs
  
function r = retrain(d,opt)
% Check if we should retrain  
 b = opt.base_recomp;
 if d<2, r=1; return; end;
 r = (floor(log(d)/log(b)) ~= floor(log(d-1)/log(b)));

% We always retrain at the end
 r = r | (d==opt.set_size);
