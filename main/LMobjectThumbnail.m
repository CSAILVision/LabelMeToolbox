function thumb = LMobjectThumbnail(annotation, HOMEIMAGES, j, tY, boundary)
% thumb = LMobjectThumbnail(annotation, HOMEIMAGES, j)
%
% Creates a thumbnail for the object index 'j'. The thumbnail will also
% show the object parts.
% 
% The function can be also called passing the image as an argument. This is
% faster when you want to create several thumbnails from the same image.
% thumb = LMobjectThumbnail(annotation, img, j)


% Thumbnail size (height)
if nargin < 4
    tY = 64;
end
if nargin < 5
    boundary = 4;
end

if isnumeric(HOMEIMAGES)
    img = HOMEIMAGES;
else
    D.annotation = annotation;
    [annotation, img] = LMread(D, 1, HOMEIMAGES);
end

[X,Y] = getLMpolygon(annotation.object(j).polygon);
X = round(X);
Y = round(Y);
[nrows ncols c] = size(img);
%area = polyarea(X,Y);

if length(tY)==1
    Dy = max(max(Y)-min(Y),max(X)-min(X));
    B = max(1, round(boundary*Dy/tY)); % extend the boundary proportionaly to what the scaling will be

    crop(1) = max(min(X)-B,1);
    crop(2) = min(max(X)+B,ncols);
    crop(3) = max(min(Y)-B,1);
    crop(4) = min(max(Y)+B,nrows);
else
    cx = (max(X)+min(X))/2;
    cy = (max(Y)+min(Y))/2;
    
    Dy = max(max(Y)-min(Y),max(X)-min(X))
    B = max(1, round(boundary*Dy/tY(1))); % extend the boundary proportionaly to what the scaling will be

    crop(1) = max(cx-Dy/2-B,1);
    crop(2) = min(cx+Dy/2+B,ncols);
    crop(3) = max(cy-Dy/2-B,1);
    crop(4) = min(cy+Dy/2+B,nrows);
    crop = round(crop);
end

% Image crop:
imgCrop = single(img(crop(3):max(crop(4), crop(3)+1), crop(1):max(crop(2), crop(1)+1), :));
imgCrop = imgCrop - min(imgCrop(:));
imgCrop = imgCrop / max(imgCrop(:));
imgCrop = uint8(256*imgCrop);
if size(imgCrop,3)==1; imgCrop = repmat(imgCrop, [1 1 3]); end

% Segmentation mask:
X = X-crop(1); Y = Y-crop(3);
s=1;
if tY(1)/max(size(imgCrop,1),size(imgCrop,2)) < .5
    s = tY(1)/max(size(imgCrop,1),size(imgCrop,2));
    imgCrop = imresize(imgCrop, s, 'bilinear');
    X = X*s;
    Y = Y*s;
end
[x,y] = meshgrid(1:size(imgCrop,2),1:size(imgCrop,1));
Mcrop = repmat(uint8(255*double(inpolygon(x, y, X, Y))), [1 1 3]);
thumb = imgCrop;

% find parts
jparts = findparts(annotation, j);
if ~isempty(jparts)
    [annotation,jj] = LMsortlayers(annotation, imgCrop);
    v = zeros(length(annotation.object),1);
    v(jparts)=1;
    v = v(jj);
    jparts = find(v);
    map = 255*hsv(length(jparts));
    for p = 1:length(jparts)
        [X,Y] = getLMpolygon(annotation.object(jparts(p)).polygon);
        X = X-crop(1); Y = Y-crop(3);
        X = round(X*s);
        Y = round(Y*s);
        Pcrop = uint8(255*double(inpolygon(x, y, X, Y)));
        Mcrop = Mcrop.*repmat(uint8(Pcrop==0),[1 1 3]);
        Mcrop(:,:,1) = Mcrop(:,:,1) + uint8(map(p,1)*Pcrop);
        Mcrop(:,:,2) = Mcrop(:,:,2) + uint8(map(p,2)*Pcrop);
        Mcrop(:,:,3) = Mcrop(:,:,3) + uint8(map(p,3)*Pcrop);
    end
end

% Final thumbnail
s = tY(1)/max(size(imgCrop,1),size(Mcrop,2));
imgCrop = imresize(imgCrop, s, 'bilinear');
%imgCrop = imgCrop(2:end-1, 2:end-1, :);
Mcrop = imresize(Mcrop, s, 'bilinear');
%Mcrop = Mcrop(2:end-1, 2:end-1, :);

thumb =  [imgCrop Mcrop];
