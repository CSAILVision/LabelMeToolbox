function [imgCrop, scaling, seg, warn, valid] = LMobjectnormalizedcrop(img, annotation, j, b, height, width)
%
% Crop object from image using a normalized frame
% [imgCrop, scaling] = LMobjectnormalizedcrop(img, annotation, j, [bh bw], height, width)
% [imgCrop, scaling] = LMobjectnormalizedcrop(img, [xmin ymin xmax ymax], j, [bh bw], height, width)
%  extract object index j from the annotation.
%
%   ------------
%   |    bh    |   b = [bh bw] = number of boundary pixels
%   |   ----   |   h = height inner bounding box
%   |bw |  |   |   w = width inner bounding box
%   |   |h |   |
%   |   ----   |
%   |    w     |
%   ------------
%

if length(b) == 1
    b = b *[1 1];
end
bh = b(1);
bw = b(2);

if isstruct(annotation)
    [X,Y,t] = getLMpolygon(annotation.object(j).polygon);
else
    xmin = annotation(1); % [xmin ymin xmax ymax]
    ymin = annotation(2); % [xmin ymin xmax ymax]
    xmax = annotation(3); % [xmin ymin xmax ymax]
    ymax = annotation(4); % [xmin ymin xmax ymax]
    X = [xmin xmin xmax xmax];
    Y = [ymin ymax ymax ymin];
    t = 1;
end
numFrames = length(t);

if nargin < 6
    % decide which dimension is larger and use 
    Dx = max(X)-min(X);
    Dy = max(Y)-min(Y);
    if Dy>Dx
        width = round(height*Dx/Dy);
    else
        % if Dx>Dy, 
        h = round(height*Dy/Dx);
        width = height;
        height = h;
    end
end

imgCrop = zeros([height+2*bh width+2*bw size(img,3) numFrames], 'uint8');
seg = zeros([height+2*bh width+2*bw numFrames], 'uint8');
valid = zeros([height+2*bh width+2*bw numFrames], 'uint8');
warn = zeros(1, numFrames);
for f = t
    if numFrames>1
        i = find(t==f); i = i(1);
        x = X(:,i);
        y = Y(:,i);
    else
        i = 1;
        x = X;
        y = Y;
    end
    
    %  bb = boundingbox = [xmin ymin xmax ymax]
    bb = [min(x) min(y) max(x) max(y)];
    
    % 1) Resize image so that object is normalized in size
    scaling = min(height/(bb(4)-bb(2)), width/(bb(3)-bb(1)));
    if numFrames>1
        [foo, I] = LMimscale([], img(:,:,:,f+1), scaling, 'bilinear');
    else
        [foo, I] = LMimscale([], img, scaling, 'bilinear');
    end
    bb = bb*scaling; x = x*scaling; y = y*scaling;
    
    % 2) pad image (just to make sure)
    margin = 5+max(width,height)+ceil(max(bh,bw)+1 + max([0 -bb(1) -bb(2) bb(4)-size(I,1) bb(3)-size(I,2)]));
    [foo, I] = LMimpad(foo, single(I), [size(I,1)+2*margin size(I,2)+2*margin], NaN);
    bb = bb+margin; x = x+margin; y = y+margin;
    
    % 2) Crop result
    cx = fix((bb(3)+bb(1))/2); cy = fix((bb(4)+bb(2))/2);
  
    bb = round([cx-width/2-bw+1 cy-height/2-bh+1 cx+width/2+bw cy+height/2+bh]);
    
    x = x - bb(1)+2; y = y - bb(2)+2;
    
    
    % Image crop:
    crop = I(bb(2):bb(4), bb(1):bb(3), :);
    imgCrop(:,:,:,i) = uint8(crop);
    
    [xx,yy] = meshgrid(1:size(imgCrop,2),1:size(imgCrop,1));
    seg(:,:,i) = uint8(255*double(inpolygon(xx, yy, x, y)));
    
    valid(:,:,i) = 1-isnan(sum(crop,3));

    % warnings by crops of scales
    warn(i) = (scaling>1) || (sum(isnan(crop(:)))>500);
end

