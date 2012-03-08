function plotBoundingBox(img, bb, score)
% Visualices and image and a set of bounding boxes
%
%   img = image
%   bb = each row is [xmin ymin xmax ymax]

Nbb = size(bb,1);
if nargin==2
    score = 3*ones(Nbb,1);
end

image(img); axis('off'); axis('equal')
if size(img,3)==1; colormap(gray(256)); end
hold on

colors = 'rrgbcmy';
for i = 1:Nbb
    plot([bb(i,1) bb(i,3) bb(i,3) bb(i,1) bb(i,1)], [bb(i,2) bb(i,2) bb(i,4) bb(i,4) bb(i,2)], 'k', 'linewidth', score(i))
    plot([bb(i,1) bb(i,3) bb(i,3) bb(i,1) bb(i,1)], [bb(i,2) bb(i,2) bb(i,4) bb(i,4) bb(i,2)], colors(mod(i,6)+1), 'linewidth', score(i)-2)
end

title(sprintf('There are %d boxes', Nbb))
