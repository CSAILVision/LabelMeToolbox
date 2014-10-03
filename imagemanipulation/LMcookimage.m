function [newannotation, newimg, crop, scaling, err, msg] = LMcookimage(annotation, img, varargin)
% Transforms an image and the annotations so that the new image has some
% characteristics such as scaling the image such that objects have a specific size.
%
% [newannotation, newimg, crop, scaling, err, msg] = LMcookimage(annotation, img, paramteters);
% This function is called by LMcookdatabase.m
%
% List of parameters
%   -----------------------
%   'imagesize'       [nrows ncols] 
%
%   'objectname'      defines which will be the object of interest
%
%   'objectsize'      [h w]: A number between 1 and inf; It is the size of the
%                     object of interest in the final image. 
%
%   'objectlocation'  Defines the location of the object in the new image. 
%                     One of these strings: 'original', 'random', 'centered'
%
%   'impad'           PADVAL. If image is smaller than 'imagesize', then it pads the image with PADVAL.
%
%   'multiplecrops'   One of these strings: 'yes', 'no'. 
%                     If there are multiple instances of the object of
%                     interest, it will create one image for each instance.
%
%   'polygoninstance' Instead of giving an object name, you can give the index to which polygon will drive the reformating.
%
%
% img = LMimread(database, 1, HOMEIMAGES); % Load image
% [newannotation, newimg, crop, scaling, err, msg] = LMcookimage(D(1).annotation, img, 'maximagesize', [256 256]);
% LMplot(newannotation, newimg)
%
% [newannotation, newimg, crop, scaling, err, msg] = LMcookimage(D(1).annotation, img, 'objectname', 'car', 'objectsize', [64 64], 'objectlocation', 'centered');
% figure; LMplot(newannotation, newimg)
%
% [newannotation, newimg, crop, scaling] = LMcookimage(D(1).annotation, img, ...
%        'objectname', 'car', ...
%        'objectsize', [64 64], 
%        'objectlocation', 'original', ...
%        'maximagesize',[128 128]);
% figure; LMplot(newannotation, newimg)
%
% when err=1 it indicates that the image transformation might have failed.
% msg provides information about the reason for failure.

msg = ''; err = 0; 

variables = {'maximagesize', 'objectname', 'objectsize', 'objectlocation', 'multiplecrops', 'impad', 'minobjectsize', 'polygoninstance'};
defaults = {[], '', [], 'original', 'no', [], [], []};
[maximagesize, objectname, objectsize, objectlocation, multiplecrops, impad, minobjectsize, polygoninstance] = ...
    parseparameters(varargin, variables, defaults);

[nrows ncols nc] = size(img);
crop = []; scaling = [];
newannotation=[];
newimg=[];
crop=[];
scaling=[];

if ~isempty(objectname) | ~isempty(polygoninstance)
    % we can specify the object of interest by
    if ~isempty(polygoninstance)
        j = polygoninstance;
    else
        annotation = LMobjectsinsideimage(annotation, img, 5);
        j = LMobjectindex(annotation, objectname);
        if length(j) == 0; err = 1; msg = 'object not present'; end
    end
end

if err == 1; return; end

if ~isempty(objectname) | ~isempty(polygoninstance)
    Ninstances = min(1,length(j));
    
    % get object bounding box
    clear cx nx cy ny crop 
    for i = 1:Ninstances
        [X,Y] = getLMpolygon(annotation.object(j(1)).polygon);
        x1(i) = min(X); x2(i) = max(X); 
        y1(i) = min(Y); y2(i) = max(Y);
        cx(i) = (x1(i)+x2(i))/2; nx(i) = (x2(i)-x1(i)); 
        cy(i) = (y1(i)+y2(i))/2; ny(i) = (y2(i)-y1(i));
    end
    
    if strcmp(multiplecrops, 'no')
        ny = min(ny); nx = min(nx); Ninstances = 1;
    end
    
    % scaling is determined by object size.
    for i = 1:Ninstances
        if isempty(objectsize)
            scaling(i) = 1;
        else
            scaling(i) = min(objectsize(1)/ny, objectsize(2)/nx);
        end
        if ~isempty(minobjectsize) & ~isempty(maximagesize)
            sc = nrows/maximagesize(1)*ny;
            
            scaling(i) = min(minobjectsize(1)/ny, minobjectsize(2)/nx);
        end
        
        % crop is determined by scaling, imagesize and location.
        if strcmp(objectlocation, 'random')
            if isempty(maximagesize)
                Dx = fix(ncols); Dy = fix(nrows);
            else
                Dx = fix(maximagesize(2)/scaling); Dy = fix(maximagesize(1)/scaling);
            end
            
            % Crop image randomly but make sure that the object is inside the cropped area:
            tx = rand; nx = fix(max(1, x2(i) - Dx)*tx + min(x1(i), ncols-Dx)*(1-tx));
            ty = rand; ny = fix(max(1, y2(i) - Dy)*ty + min(y1(i), nrows-Dy)*(1-ty));
            crop(:,i) = round([nx nx+Dx ny ny+Dy]);
        end
        
        if strcmp(objectlocation, 'centered')
            if isempty(maximagesize)
                Dx = fix(ncols/2); Dy = fix(nrows/2);
            else
                Dx = fix(maximagesize(2)/2/scaling); Dy = fix(maximagesize(1)/2/scaling);
            end
            Dx = min([cx Dx ncols-cx]);
            Dy = min([cy Dy nrows-cy]);
            crop(:,i) = round([cx-fix(Dx) cx+ceil(Dx) cy-fix(Dy) cy+ceil(Dy)]);
        end
        
        if strcmp(objectlocation, 'original')
            % try to maintain the same object location (relative to the
            % frame) without cropping the object.
            if isempty(maximagesize)
                crop = [];
            else
                px = cx/ncols;
                py = cy/nrows;
                ms = round(maximagesize/scaling);
                ncx = round(ms(2)*px); ncy = round(ms(1)*py); % new center coordinates.
                
                % take care that the object is not cropped. 
                x1 = max([min([cx-ncx, cx-nx/2]) 1 cx+nx/2-ms(2)]);
                x2 = min([x1+ms(2) ncols]);
                y1 = max([min(cy-ncy, cy-ny/2) 1 cy+ny/2-ms(1)]);
                y2 = min([y1+ms(1) nrows]);
                
                crop(:,i) = round([x1 x2 y1 y2]);
            end
        end
    end
else
    scaling = min(maximagesize(1)/nrows, maximagesize(2)/ncols);
    crop = ceil([1 maximagesize(2)/scaling 1 maximagesize(1)/scaling]);
end

if isempty(crop); crop = [1 size(img,2) 1 size(img,1)]; end
if isempty(scaling); scaling = 1; end
    
[newannotation, newimg, crop] = LMimcrop(annotation, img, crop);
[newannotation, newimg] = LMimscale(newannotation, newimg, scaling, 'bilinear');

if ~isempty(maximagesize)
    if size(newimg,1)>maximagesize(1) | size(newimg,2)>maximagesize(2)
        [newannotation, newimg] = LMimcrop(newannotation, newimg, [1 maximagesize(2) 1 maximagesize(1)]);
    end
    if ~isempty(impad)
        % pad image
        [newannotation, newimg] = LMimpad(newannotation, newimg, maximagesize, impad);
    end
end

% Remove annotations that are outside of the image boundary
newannotation = LMobjectsinsideimage(newannotation, newimg, 0);


if scaling > 1;
    err = 1;
    msg = [msg; 'WARNING: The image has been upsampled. This will produce blur.'];
end


