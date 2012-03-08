function [X, Y] = segment2polygon(mask)

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
    
    % simplify polygon:
    for iter =1:2
        L = length(X);
        n = 2;
        while n < length(X)
            v1 = [X(n+1)-X(n) Y(n+1)-Y(n)];
            v2 = [X(n)-X(n-1) Y(n)-Y(n-1)];
            v1 = v1/sqrt(sum(v1.^2));
            v2 = v2/sqrt(sum(v2.^2));
            if v1*v2' > .7
                X = [X(1:n-1); X(n+1:end)];
                Y = [Y(1:n-1); Y(n+1:end)];
            else
                n = n+1;
            end
        end
    end
else
    X = [];
    Y = [];
end

