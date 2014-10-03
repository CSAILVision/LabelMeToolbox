function [Dq, j] = LMquerypolygon(D, objectname, Xo, Yo, threshold)
%
% Search the database for images that contain an object matching a query
% shape.
%
% [Dq, j] = LMquerypolygon(D, objectname, Xo, Yo, threshold)
%
% The output arguments are the same than for the function LMquery

if nargin<5
    threshold = .7;
end

[Dd, j] = LMquery(D, 'object.name', objectname);
Dd = D(j);

% For each image, extract object polygon and compute overlap.
ii = 0; 
matches = 0;
clear Dq;
j2 = zeros(1,length(Dd));
for i = 1:length(Dd)
    k = LMobjectindex(Dd(i).annotation, objectname);
    if ~isempty(j)
        clear overlap
        for n = 1:length(k) % only consider the first instance
            [X,Y] = getLMpolygon(Dd(i).annotation.object(k(n)).polygon);
            overlap(n) = overlapping(X, Y, Xo, Yo);
        end
        jj = find(overlap>threshold);

        if ~isempty(jj)
            matches = matches + length(jj);
            ii = ii+1;
            Dq(ii) = Dd(i);
            Dq(ii).annotation.object = Dd(i).annotation.object(k(jj));
            j2(ii) = i;
        end
    end
end

% select final indices 
j = j(j2(1:ii));

disp(sprintf('%d polygons matched the target out of %d images', matches, length(D)))


function overlap = overlapping(X1, Y1, X2, Y2)
n = 1;
m = 1;

c1 = [(max(X1)+min(X1))/2 (max(Y1)+min(Y1))/2];
D1 = [(max(X1)-min(X1))   (max(Y1)-min(Y1))];
c2 = [(max(X2)+min(X2))/2 (max(Y2)+min(Y2))/2];
D2 = [(max(X2)-min(X2))   (max(Y2)-min(Y2))];

X1 = (X1 - c1(1))/max(D1);
Y1 = (Y1 - c1(2))/max(D1);
X2 = (X2 - c2(1))/max(D2);
Y2 = (Y2 - c2(2))/max(D2);

% % PASCAL measure:
% overlap = intersection / ua;
[intersection, union] = polyintersect(double(X1), double(Y1), double(X2), double(Y2));
overlap = intersection / union;




