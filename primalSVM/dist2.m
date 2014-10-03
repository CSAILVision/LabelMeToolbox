function K = dist2(X1, X2)

norm1 = sum(X1.^2,2);
norm2 = sum(X2.^2,2);

K = (repmat(norm1 ,1,size(X2,1)) + ...
    repmat(norm2',size(X1,1),1) - ...
    2*X1*X2');

