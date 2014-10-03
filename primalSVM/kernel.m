function K = kernel(X1, X2, param)

n1 = size(X1,1);
n2 = size(X2,1);
d = size(X1,2);
switch param.type
    case 'linear'
        K = X1*X2';
        
    case 'rbf'
        norm1 = sum(X1.^2,2);
        norm2 = sum(X2.^2,2);
        dist = (repmat(norm1 ,1,size(X2,1)) + ...
            repmat(norm2',size(X1,1),1) - ...
            2*X1*X2');        
        K = exp(-0.5/param.sig^2 * dist);

    case 'dist'
        norm1 = sum(X1.^2,2);
        norm2 = sum(X2.^2,2);
        dist = (repmat(norm1 ,1,size(X2,1)) + ...
            repmat(norm2',size(X1,1),1) - ...
            2*X1*X2');
        K = param.maxdist - dist;
        
    case 'Lp'
        K = zeros(n1,n2);
        for n = 1:n1
            K(n,:) = real(sum(bsxfun(@minus, X2, X1(n,:)).^param.p,2));
        end
        K = exp(-0.5/param.sig^2 * K);

    case 'L1'
        K = zeros(n1,n2);
        for n = 1:n1
            K(n,:) = real(sum(abs(bsxfun(@minus, X2, X1(n,:))),2));
        end
        K = exp(-0.5/param.sig * K);
        
    case 'histintersection'
		K = zeros(n1,n2);
        for n = 1:n1
            K(n,:) = sum(bsxfun(@min, X2, X1(n,:)),2);
        end
		
    case 'L1_james'
        K = zeros(n1,n2);
        for n = 1:n1
            K(n,:) = real(sum(abs(bsxfun(@minus, X2, X1(n,:))),2));
        end
        K = max(max(K)) - K;
        
    otherwise
        error('Unknown kernel');
end;

