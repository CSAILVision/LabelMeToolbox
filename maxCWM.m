function [m, S]=maxCWM(x,p,mx,Cx,Cy,b)
%
% Regressor by non-linear mixture of linear regressors
% Input
%    x = data
%    p,mx,Cx,Cy,b = parameters regressor

[Nf Nt] = size(x);
Nc=length(p);
a=zeros(1,Nc);

for j=1:Nc
    xm=x-mx(:,j);
    iXa=inv(Cx(:,:,j));
    xmX=iXa'*xm;
    dxm=dot(xmX,xm)';
    a(j) = log(p(j)) -0.5*dxm -log(sqrt(det(Cx(:,:,j)))/(2*pi)^(Nf/2));
end

a = a-max(a);
gx = exp(a);

m=0;
for j=1:Nc
    m = m + (b(:,:,j)*[1; xm]) * gx(j);
end
m = m / sum(gx);

[foo, k] = max(gx);
S = Cy(:,:,k);
