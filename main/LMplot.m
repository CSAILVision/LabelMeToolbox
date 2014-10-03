function [h, class] = LMplot(varargin)
% Visualizes the polygons in an image.
%
% LMplot(annotation, img)
% or
% LMplot(database, ndx, HOMEIMAGES)
%
% Example:
%   [annotation, img] = LMread(filename, HOMEIMAGES)
%   LMplot(annotation, img)
%
%   thumbnail = size of the image
%   The plot uses only 7 colors, therefore, some times, different object.
%   Classes might have the same color assigned.
%
% If an object has the field 'confidence', the thickness of the bounding
% box will be equal to the confidence.
%
% If the object has the filed 'detection', then when the state is 'false'
% it will show the outline in green, and when the state is 'correct' it
% will show the outline in red.

switch length(varargin)
   case 1
       annotation = varargin{1};
       img = -1;
   case 2
       annotation = varargin{1};
       img = varargin{2};
   case 3
       D = varargin{1};
       ndx = varargin{2};
       
       if ndx>length(D)
           return
       end
       
       HOMEIMAGES = varargin{3};

       annotation = D(ndx).annotation;
       %img = imread(fullfile(HOMEIMAGES, annotation.folder, annotation.filename));
       img = LMimread(D, ndx, HOMEIMAGES); % Load image
   otherwise
       error('Too many input arguments.')
end

% Define colors
colors = 'rgbcmyw';
colors = hsv(15);

% Draw image
%figure;
if size(img,1)>1
    if isfloat(img)
        img = img-min(img(:));
        img = 255*img/max(img(:));
    end
    image(uint8(img)); axis('off'); axis('equal'); hold on
    if size(img,3) == 1
        colormap(gray(256))
    end
else
    axis('off'); axis('equal'); axis('ij'); hold on
end

% Draw each object (only non deleted ones)
h = []; class = [];
if isfield(annotation, 'object')
   Nobjects = length(annotation.object); n=0;
   for i = 1:Nobjects
       n = n+1;
       class{n} = annotation.object(i).name; % get object name
       col = colors(mod(sum(double(class{n})),15)+1, :);
       [X,Y] = getLMpolygon(annotation.object(i).polygon);
       X = double(X(:)); Y = double(Y(:));
       
       LineWidth = 4;
       if isfield(annotation.object(i), 'parts') && isfield(annotation.object(i).parts, 'ispartof')
           if ~isempty(annotation.object(i).parts.ispartof)
               class{n} = [class{n} ' (part)'];
               LineWidth = 1.5;
           end
       end

       if isfield(annotation.object(i), 'confidence')
           p = annotation.object(i).confidence;
           class{n} = [class{n} sprintf('[%2.2f]',p)];
           
           LineWidth = round(annotation.object(i).confidence);
           LineWidth = min(max([2 LineWidth]), 8);
           
           if isfield(annotation.object(i), 'detection')
               if strcmp(annotation.object(i).detection, 'false')
                   LineWidth = 1; %col = 'g';
               else
                   LineWidth = 4; %col = 'r';
               end
           end

           
           
           
           dim = get(gca,'position');
           if dim(3)>.5
               % If the plot occupies the entire figure, then we can plot the
               % confidence as a string.
               hold on
               xx = mean(X);
               %yy = mean(Y);
               yy = min(Y);
               ht=text(xx,yy, ...
                   sprintf('%5.2f', annotation.object(i).confidence), ...
                   'horizontalAlignment', 'center', 'verticalAlignment', 'bottom');
               %sprintf('%d %5.3f', i, annotation.object(i).confidence), ...
               %'horizontalAlignment', 'center', 'verticalAlignment', 'bottom');

               set(ht, 'color', col, 'fontsize', 10);
           else              
               xx = mean(X);
               %yy = mean(Y);
               yy = min(Y);
               ht=text(xx,yy, class{n}, 'horizontalAlignment', 'center', 'verticalAlignment', 'bottom');
               set(ht, 'color', col, 'fontsize', 10);
           end
       end

       plot([X; X(1)],[Y; Y(1)], 'LineWidth', LineWidth, 'color', [0 0 0]); hold on
       h(n) = plot([X; X(1)],[Y; Y(1)], 'LineWidth', LineWidth/2, 'color', col);
       hold on
   end

   if nargout == 0
       legend(h, class);
   end
   %drawnow
end

