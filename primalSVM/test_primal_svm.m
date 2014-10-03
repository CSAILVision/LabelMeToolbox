global X K
% Generating 3000 points in 100 dimensions
X = randn(3000,100);
Y = sign(X(:,1));

% create a linear kernel:
K = X*X';
lambda = 1;

[w,   b0 ]=primal_svm(1,Y,lambda); 
[beta,b]=primal_svm(0,Y,lambda);

% The solutions are the same because the kernel is linear !
norm( K*beta+b - (X*w+b0)) 

% Try to now solve by conjugate gradient
opt.cg = 1;
[w,   b0 ]=primal_svm(1,Y,lambda,opt); 
[beta,b]=primal_svm(0,Y,lambda,opt);

norm( K*beta+b - (X*w+b0))

% Sparse linear problem
X = sprandn(1e5,1e4,1e-3);
Y = sign(sum(X,2)+randn(1e5,1));
[w,b]=primal_svm(1,Y,lambda); 

