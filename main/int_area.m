function A = int_area(X1,Y1,X2,Y2)
% Compute area of intersection:
%
% area = int_area(X1,Y1,X2,Y2)

X1 = double(X1);
Y1 = double(Y1);
X2 = double(X2);
Y2 = double(Y2);

max_res = 100;

min_x = min([X1(:); X2(:)]);
max_x = max([X1(:); X2(:)]);
min_y = min([Y1(:); Y2(:)]);
max_y = max([Y1(:); Y2(:)]);

X1 = X1-min_x;
X2 = X2-min_x;
Y1 = Y1-min_y;
Y2 = Y2-min_y;
max_x = max_x - min_x;
max_y = max_y - min_y;

max_dim = max(max_x,max_y);

ratio = 1;
% $$$   if max_dim > max_res
% $$$     ratio = max_res/max_dim;
% $$$     X1 = X1*ratio;
% $$$     X2 = X2*ratio;
% $$$     Y1 = Y1*ratio;
% $$$     Y2 = Y2*ratio;
% $$$     max_x = round(max_x*ratio);
% $$$     max_y = round(max_y*ratio);
% $$$   end

X1 = X1+1; X2 = X2+1;
Y1 = Y1+1; Y2 = Y2+1;
max_x = ceil(max_x+1); 
max_y = ceil(max_y+1);

M1 = poly2mask(X1,Y1,max_y,max_x);
M2 = poly2mask(X2,Y2,max_y,max_x);

A = sum(sum(double(M1&M2)))/ratio;
