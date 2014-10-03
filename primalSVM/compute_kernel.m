% function K = compute_kernel(ind1,ind2,hp)
% global X
% switch hp.type
%     
%     case 'linear'
%         K = X(ind1,:)*X(ind2,:)';
%         
%     case 'rbf'
%         if isempty(ind2)
%             K = ones(length(ind1),1);
%             return;
%         end;
%         normX = sum(X(ind1,:).^2,2);
%         normY = sum(X(ind2,:).^2,2);
%         K = exp(-0.5/hp.sig^2*(repmat(normX ,1,length(ind2)) + ...
%             repmat(normY',length(ind1),1) - ...
%             2*X(ind1,:)*X(ind2,:)'));
%     otherwise
%         error('Unknown kernel');
% end;
% 
% 
function K = kernel(X1, X2, param)
switch param.type
    case 'linear'
        K = X1*X2';
        
    case 'rbf'
        norm1 = sum(X1.^2,2);
        norm2 = sum(X2.^2,2);
        K = exp(-0.5/param.sig^2 *...
            (repmat(norm1 ,1,size(X2,1)) + ...
            repmat(norm2',size(X1,1),1) - ...
            2*X1*X2'));
    otherwise
        error('Unknown kernel');
end;

