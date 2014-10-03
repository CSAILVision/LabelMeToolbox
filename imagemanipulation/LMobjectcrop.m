function [imgCrop, mask, X, Y] = LMobjectcrop(img, annotation, j, b)
%
% Crop object from image
%
% imgCrop = LMobjectcrop(img, annotation, j, b)
%
% also returns the segmentation mask

if nargin == 3
    b = 2;
end

[nrows, ncols, cc] = size(img);

[X,Y] = getLMpolygon(annotation.object(j).polygon);

crop(1) = max(min(X)-b,1);
crop(2) = min(max(X)+b,ncols);
crop(3) = max(min(Y)-b,1);
crop(4) = min(max(Y)+b,nrows);
crop = round(crop);

% Image crop:
imgCrop = img(crop(3):crop(4), crop(1):crop(2), :);

% Segmentation mask
if nargout > 1
    X = X-crop(1);
    Y = Y-crop(3);
    [x,y] = meshgrid(1:size(imgCrop,2),1:size(imgCrop,1));
    mask = logical(inpolygon(x, y, X, Y));
end
