function [imgAligned, annotationAligned] = LMobjectalign(img, annotation, j, targetImage, targetBoundingBox)

PADVAL = 0;
annotationAligned = [];

[nrows, ncols, cc] = size(targetImage);

bb = LMobjectboundingbox(annotation, j);


scaling = min((targetBoundingBox(4)-targetBoundingBox(2))/(bb(4)-bb(2)), (targetBoundingBox(3)-targetBoundingBox(1))/(bb(3)-bb(1)));

% scale image
[annotation, img] = LMimscale(annotation, img, scaling, 'bilinear');


% centered crop
bb = LMobjectboundingbox(annotation, j);

Dx = round((targetBoundingBox(3)+targetBoundingBox(1))/2 - (bb(3)+bb(1))/2);
Dy = round((targetBoundingBox(4)+targetBoundingBox(2))/2 - (bb(4)+bb(2))/2);

imgAligned = img;

if Dy<0
    imgAligned = imgAligned(-Dy:end, :,:);
else
    imgAligned = cat(1, repmat(PADVAL, [Dy size(imgAligned,2) cc]), imgAligned);
end

if Dx<0
    imgAligned = imgAligned(:,-Dx:end,:);
else
    imgAligned = cat(2, repmat(PADVAL, [size(imgAligned,1) Dx cc]), imgAligned);
end

if size(imgAligned,1)>nrows
    imgAligned = imgAligned(1:nrows,:,:);
else
    D = nrows - size(imgAligned,1);
    imgAligned = cat(1, imgAligned, repmat(PADVAL, [D size(imgAligned,2) cc]));
end

if size(imgAligned,2)>ncols
    imgAligned = imgAligned(:,1:ncols,:);
else
    D = ncols - size(imgAligned,2);
    imgAligned = cat(2, imgAligned, repmat(PADVAL, [size(imgAligned,1) D cc]));
end


%figure
%subplot(121)
%imshow(img)
%subplot(121)
%imshow(imgAligned/2+targetImage/2)

