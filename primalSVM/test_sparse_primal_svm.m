clear; randn('state',1);
global X K

n = 1000;
nt = 3000;
d = 10;
fprintf('Problem of learning a spherical boundary\n');
fprintf('Generating %d noisy training points in %d dimensions\n',n,d)

X = randn(n+nt,d);
Y = 2* (sum(X.^2,2) > d*(1-0.1*randn(n+nt,1)))-1;
fprintf('Error Bayes classifier = %f\n',mean(Y.*(sum(X.^2,2)-d)<0));

hp.type = 'rbf';
hp.sig = sqrt(d);
C = 1;

tic;
K = compute_kernel(1:n,1:n,hp);
[alpha,b,obj0] = primal_svm(0,Y(1:n),1/C); 
time0 = toc;
te0 = mean(Y(n+1:n+nt).*(compute_kernel(n+1:n+nt,1:n,hp)*alpha+b)<0);
fprintf('Test error full SVM = %f, Time = %2.2f sec\n',te0,time0);
nsv = length(find(alpha));

opt.set_size=32;
[alpha,b,S,obj,te,time] = sparse_primal_svm(Y(1:n),Y(n+1:end),...
                                            @compute_kernel,hp,C,opt);

fprintf('Time = %2.2f sec\n',sum(time));
sz = unique(round((2^0.25).^[1:10+length(obj)]));
scale = te(1)/obj(1);
semilogx(sz(1:length(obj)),[te; obj*scale]);
hold on
plot(nsv,[te0 obj0*scale*C],'o');
hold off
legend('Test error','Objective function (scaled)','Full SVM','Full SVM');
xlabel('Number of basis functions');

fprintf('About 10 basis functions are enough for this problem\n')