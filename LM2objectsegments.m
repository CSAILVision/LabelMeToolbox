function [imgCrop, seg] = LM2objectsegments(D, HOMEIMAGES, b, height, width)
%
% [imgCrop, seg] = LM2objectsegments(D, HOMEIMAGES, b, height, width)
%
%   ------------
%   |     b    |   b = number of boundary pixels
%   |   ----   |   h = height inner bounding box
%   | b |  |   |   w = width inner bounding box
%   |   |h |   |
%   |   ----   |
%   |    w     |
%   ------------
%

counts = LMcountobject(D);
Nobjects = sum(counts);
Nimages = length(D);

imgCrop = zeros([height+2*b width+2*b 3 Nobjects], 'uint8');
seg = zeros([height+2*b width+2*b 1 Nobjects], 'uint8');


k=0;
for n = 1:Nimages
    disp(n)
    
    % Load image
    img = LMimread(D, n, HOMEIMAGES);
    if size(img,3)==1
        img = repmat(img, [1 1 3]);
    end
    
    annotation = D(n).annotation;
    
    for m = 1:counts(n)
        k = k+1;
        [imgCrop(:,:,:,k), scaling, seg(:,:,1,k), warn] = LMobjectnormalizedcrop(img, annotation, m, b, height, width);
    end
end

