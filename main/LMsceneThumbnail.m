function thumb = LMsceneThumbnail(annotation, HOMEIMAGES, img, style, tY)
% thumb = LMsceneThumbnail(annotation, HOMEIMAGES, img, style)
% 
% This function returns a thumbnail with the style used on the online tool.
%
% There are two styles
%     style = 'shaded' [default], 'lines'
%
% HOMEIMAGES = 'http://labelme.csail.mit.edu/Images';

% Thumbnail size (height)
if nargin<5
    tY = 96;
end
%tY = 160;

D.annotation = annotation;
if nargin < 3
    img = LMimread(D, 1, HOMEIMAGES);
end
if nargin > 3
    if isempty(img)
        img = LMimread(D, 1, HOMEIMAGES);
    end
end

if nargin < 4
    style = 'shaded';
end

% Re-scale image
[annotation, img] = LMimscale(annotation, img, (tY+1)/size(img,1), 'bilinear');
[annotation, img] = LMimcrop(annotation, img, [1 size(img,2) 1 tY]);

if size(img,3) < 3
    img = repmat(img(:,:,1), [1 1 3]);
end

% sort layers
annotation = LMsortlayers(annotation, img);


% get segmentation masks
[mask, cc, maskpol, classpol] = LMobjectmask(annotation, [size(img,1) size(img,2)]);

% Thumbnails
switch style
    case 'shaded'
        % Thumbnails with masks
        seg = 128*ones(size(img));
        if size(mask,3)>0
            M = double(colorSegments(mask, 'donotsort'))/255;
            if size(M,1)>0
                M = M + .5*repmat(sum(mask,3)==0, [1 1 3]);
                M = M / max(M(:));
                seg = M .* repmat(mean(double(img),3)/2+128, [1 1 3]);
            end
        end
    case 'lines'
        % Thumbnails with polygons
        seg = img;
        if prod(size(mask))>0
            colors   =  hsv(size(mask,3));
            % black boundary
            Th = 3; cB = strel('disk',2); cL = strel('disk',1);
            for n = 1:size(mask,3)
                boundary = bwperim(mask(:,:,n),8);
                boundaryB = imdilate(boundary, cB);
                seg = seg.*uint8(repmat(1-boundaryB, [1 1 3]));
                boundaryL = double(imdilate(boundary, cL));
                for m = 1:3; seg(:,:,m) = seg(:,:,m)+uint8(255*boundaryL*colors(n,m)); end
            end
        end
end

seg = uint8(seg);
thumb = [img 255*ones([size(img,1),2,size(img,3)]) seg];

if nargout == 0
    figure
    imshow(thumb)
end

