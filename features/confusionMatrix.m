function C = confusionMatrix(z1, z2, names1, names2)
% Normalized with respect to z1
% Input
%   z1 = true class for each sample
%   z2 = assigned class to each sample
%   names1 = name for the true classes
%   names2 = you can add a second list if the output classes do not have
%       the same names.
% Output
%   C = confusion matrix, such that:
%     C(i,j) = percentage of times that class i (z1=i) is assigned to class j (z2=j)
%     sum(C(i,:)) = 100

if nargin<4
    names2 = names1;
end

cl1 = unique(z1);
cl2 = unique(z2);
n = length(cl1);
m = length(cl2);
%n = max(n,m);
%m = n;

C = zeros([n m]);
for i = 1:n
    for j = 1:m
        C(i,j) = 100*sum((z1==cl1(i)).*(z2==cl2(j))) / sum(z1==cl1(i));
    end
end

% plot confusion matrix
figure
subplot(121)
showMatrix(C, 100)
%imagesc(C, [0 100]); axis('square'); colorbar
%for i = 1:n
%    for j = 1:m
%        text(i,j,num2str(round(C(i,j))), 'fontsize', 8, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
%    end
%end
ha = gca;
subplot(122)
bar(diag(C))
title(round(100*mean(diag(C)))/100)
axis('square')
label = strrep(names1, '_',' ');
label = strrep(label, '/', ' ');
t = [1:1:length(label)];
set(ha, 'YTick', t);
set(ha, 'YTickLabel', label(t))

label = strrep(names2, '_',' ');
label = strrep(label, '/', ' ');
t = [1:1:length(label)];
set(ha, 'XTick', t);
set(ha, 'XTickLabel', label(t))
set(ha, 'FontSize', 12)
%set(ha, 'FontSize', 4)



if nargin == 3
    
    % dendrogram
    W = max(C(:))-C;
    W = exp(-1*C);
    
    Y = W-diag(diag(W));
    Yn = Y ./ repmat(1+diag(Y), [1 size(Y,1)]);

    Yn = max(Yn, Yn');
    Yn = min(Yn,1)
    
    Y = squareform(Yn);
    Z = linkage(Y,'average');
    
    figure
    [H,T,perm] = dendrogram(Z,0);
    set(H,'LineWidth',2)
    
    
   % keyboard
    %Cn = C ./ repmat(1+diag(C), [1 size(C,1)])
    %W = (Cn+Cn')/2;
    %W = min(W,1);
    
    %D12 = diag(sqrt(sum(W,1)));
    %[a,b] = eig(inv(D12)*W*inv(D12));
    %[foo, perm] = sort(a(:,end));
    Cperm = C(perm,perm);
    %Cperm = Yn(perm,perm);
    figure
    %imagesc(Cperm, [0 min(50,max(Cperm(:)))]); axis('equal'); %colormap(gray(256))
    showMatrix(Cperm, 50)
    %image((Cperm-diag(diag(Cperm))));
    %caxis([0 30])
    axis('equal');
    map = jet(256);
    %map = map(end:-1:1,:);
    %map = 1-map;
    %map = [map; repmat(map(end,:), [128+32 1])];
    colormap([0 0 0; map])
    colorbar
    axis('tight')
    ha = gca;
   
    label = strrep(names1(perm), '_',' ');
    label = strrep(label, '/', ' ');
    
    t = [1:1:length(names1)];
    set(ha, 'YTick', t);
    set(ha, 'YTickLabel', label(t))
    set(ha, 'FontSize', 10)
    set(ha, 'XTick', t);
    set(ha, 'XTickLabel', label(t))
   %orient tall
    
    
end



