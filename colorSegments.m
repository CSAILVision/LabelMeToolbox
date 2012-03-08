function img = colorSegments(cube, method)
% Transforms the segmentation mask into a color image. This  function is
% just intended as a visualization tool. 
% It might introduce artifacts if you try to use this function for segmenting objects.

[nrows, ncols, ncolor] = size(cube);
cube = double(reshape(cube, [nrows*ncols ncolor]));

if nargin == 1
    % Sort segments from smaller to larger and visualize with occlusions
    area = squeeze(sum(cube, 1));
    [foo, k] = sort(-area);
    cube = cube(:,k);
end

mask = zeros([nrows*ncols 1]);
for i = ncolor:-1:1
    cube(:,i) = cube(:,i).*(1-mask);
    mask = mask+cube(:,i);
end


map = hsv(ncolor);
map = map(randperm(ncolor),:);

img = cube * map;
img = reshape(img, [nrows ncols 3]);
img(img>1) = 1;
img = uint8(255*img);


