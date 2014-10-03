function [bb] = segment2polygon(mask)
%bb = each row is [xmin ymin xmax ymax]
se = strel('disk',3);
mask = imclose(mask, se);

[B,L] = bwboundaries(mask, 'noholes');

N = zeros(length(B),1);
if ~isempty(B)
    for k = 1:length(B)
        N(k) = size(B{k}(:,1),1);
    end

    [M,k] = max(N);
    X = B{k}(:,2);
    Y = B{k}(:,1);
    
    bb = [min(X) min(Y) max(X) max(Y)];
else
    bb = [];
end

