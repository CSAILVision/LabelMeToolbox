function [mask, class, maskpol, classpol] = LMobjectmask(annotation, var, objectlist) 
% Returns a segmentation mask for all the objects in the annotation struct
% This function  generates segmentation masks for all
% the annotated objects in the order that they are present. Multiple
% intances of the same object also get separated masks.
%
% Uses:
%  [mask, class] = LMobjectmask(annotation, [nrows ncols]);
%  [mask, class] = LMobjectmask(annotation, HOMEIMAGES);
%
%
% If you specify a list of objects, then the behavior of the function
% changes. Now 'mask' will put together objects of the same class.
%  [mask, class] = LMobjectmask(annotation, HOMEIMAGES, objectlist)
%  [mask, class, maskpol, classpol] = LMobjectmask(annotation, HOMEIMAGES, objectlist)
%
%  Without output arguments, the function plots the segmentation masks using an
%  arbitrary color coding.
%
% Variables:
%  mask: is a 3D logical array (pixel = 1 => object present)
%  class: is the name of all the objects.
%  maskpol: is a mask for each polygon in the annotation.
%  classpol: is the class number assigned to each instance.
%
% Example:
%   [D,j] = LMquery(database, 'name', 'car+side');
%   mask = LMobjectmask(database(j(1)).annotation, HOMEIMAGES, 'car+side,building,road');
%   figure; imagesc(double(mask));
% The logical matrix 'mask' will be of size [n x m x 3] because there are three objects.


maskpol = []; classpol = [];

if nargin == 1
    error('Not enough input arguments.')
end

if nargin > 1
    if ischar(var)
        HOMEIMAGES = var; % you can set here your default folder
        info = imfinfo(fullfile(HOMEIMAGES, annotation.folder, annotation.filename));
        nrows = info.Height;
        ncols = info.Width;
    else
        nrows = var(1);
        ncols = var(2);
    end
end

if nargin == 2
    % if a list is not specified it generates segmentation masks for all
    % the annotated objects in the order that they are present. Multiple
    % intances of the same object also get separated masks.
    class = []; mask = [];
    if isfield(annotation, 'object')
        Nobjects = length(annotation.object);
        %[x,y] = meshgrid(1:ncols,1:nrows);

        mask = zeros([nrows, ncols, Nobjects]);
        for i = 1:Nobjects
            class{i} = annotation.object(i).name; % get object name
            [X,Y] = getLMpolygon(annotation.object(i).polygon);
            
            mask(:,:,i) = poly2mask(double(X),double(Y),nrows,ncols);
            %mask(:,:,i) = logical(inpolygon(x, y, X, Y));
        end
    end
end

if nargin == 3
    if isfield(annotation, 'object')
        Nobjects = length(annotation.object); ni=0;
        maskpol = logical(zeros(nrows, ncols, Nobjects));
        classpol = zeros(Nobjects,1);

        class = []; mask = [];
        j = strfind(objectlist,','); j = [0 j length(objectlist)+1];
        mask = logical(zeros(nrows, ncols, length(j)-1));

        for i = 1:length(j)-1
            class{i} = objectlist(j(i)+1:j(i+1)-1); % get object name

            jc = LMobjectindex(annotation, class{i});
            for n = 1:length(jc)
                [X,Y] = getLMpolygon(annotation.object(jc(n)).polygon);
                ni = ni+1;
                maskpol(:,:,ni) = poly2mask(double(X),double(Y),nrows,ncols);
                classpol(ni) = i;
                mask(:,:,i) = mask(:,:,i) | maskpol(:,:,ni);
            end
        end
        maskpol = maskpol(:,:,1:ni);
        classpol = classpol(1:ni);
    else
        mask = logical(zeros(nrows, ncols, 1));
        class = [];
    end
end

if nargout ==0;
    seg = colorSegments(mask);
    imshow(seg);
end

