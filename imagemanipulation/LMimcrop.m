function [annotation, img, crop] = LMimcrop(annotation, img, crop)
%
% Crops an image and modifies the corresponding annotation.
%
% [annotation, img] = LMimcrop(annotation, img, [xmin xmax ymin ymax]);
%

% First check that it is a valid crop
[nrows ncols c] = size(img);
crop(1) = max(crop(1),1);
crop(2) = min(crop(2),ncols);
crop(3) = max(crop(3),1);
crop(4) = min(crop(4),nrows);

% Image crop:
img = img(crop(3):crop(4), crop(1):crop(2), :);
[nrows ncols c] = size(img);

% Change the size of the polygon coordinates
if isfield(annotation, 'object')
    Nobjects = length(annotation.object); n=0;
    for i = 1:Nobjects
        [x,y] = getLMpolygon(annotation.object(i).polygon);
        x = round(x - crop(1) +1); % crop(1) = 1 implies no crop;
        y = round(y - crop(3) +1);
        annotation.object(i).polygon = setLMpolygon(x,y);


%         Npoints = length(annotation.object(i).polygon.pt);
%         clear X Y
%         for j = 1:Npoints
%             % Scale each point:
%             x=str2num(annotation.object(i).polygon.pt(j).x);
%             y=str2num(annotation.object(i).polygon.pt(j).y);
% 
%             X(j) = round(x - crop(1) +1); % crop(1) = 1 implies no crop
%             Y(j) = round(y - crop(3) +1);
% 
%             annotation.object(i).polygon.pt(j).x = num2str(X(j));
%             annotation.object(i).polygon.pt(j).y = num2str(Y(j));
%         end
        % If the object is outside the image, mark as deleted
        if max(x)<0 | max(y)<0 | min(x)>ncols | min(y)>nrows
            annotation.object(i).deleted = '1';
        end
    end
end
