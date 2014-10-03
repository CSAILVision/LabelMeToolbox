function showSpaceImages(img, x, y, scaling, limits)
%
% Displays images organized in a 2D space
%
% input:
%   img: array [nrows ncols 3 nimages]
%   x,y  = coordinate for each image

if nargin<5
    x1 = min(x(:));
    y1 = min(y(:));
    x2 = max(x(:));
    y2 = max(y(:));
else
    x1 = limits(1);
    x2 = limits(2);
    y1 = limits(3);
    y2 = limits(4);
end

%xa = x - min(x(:));
%ya = y - min(y(:));

if nargin<4
    scaling = 2;
end

%S = max(xa);
%xa = (0.975-0.05*scaling)*xa/S+0.025;
%S = max(ya);
%ya = (0.975-0.05*scaling)*ya/S+0.025;


xa = (0.975-0.05*scaling)*(x - x1)/(x2-x1) + 0.05*scaling;
ya = (0.975-0.05*scaling)*(y - y1)/(y2-y1) + 0.05*scaling;

figure
for n = length(xa):-1:1
    n
    h=axes('position', [xa(n) ya(n) .05*scaling .05*scaling]);
    image(uint8(img(:,:,:,n)), 'parent', h)
    axis('off'); axis('equal')
end

