function showSpaceImages(img, x, y, scaling)
%
% Displays images organized in a 2D space
%
% input:
%   img: array [nrows ncols 3 nimages]
%   x,y  = coordinate for each image

xa = x - min(x(:));
ya = y - min(y(:));

if nargin<4
    scaling = 2;
end

S = max(xa);
xa = .925*xa/S+0.025;
S = max(ya);
ya = .925*ya/S+0.025;

figure
for n = length(xa):-1:1
    h=axes('position', [xa(n) ya(n) .05*scaling .05*scaling]);
    image(uint8(img(:,:,:,n)), 'parent', h)
    axis('off'); axis('equal')
end

