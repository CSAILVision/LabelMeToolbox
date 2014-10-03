function [annotation, img] = LMimscale(annotation, img, scaling, method)
%
% Scales one image (as in imresize) and the associated annotation.
% The scale factor is given by 'scaling'.
% 
% When scaling<1, the image is downsampled.
%
% [annotation, img] = LMimscale(annotation, img, scaling);
%
% or, if you are using the LabelMe struct D:
% 
% [D(i).annotation, img] = LMimscale(D(i).annotation, img, scaling);
%
% Also, the scaling can be given in absolute coordinates:
%
% [annotation, img] = LMimscale(annotation, img, [NROWS NCOLS]);

% Store the original numerical format of the image and turn it into 'double'.


imgtype = whos('img');
img = single(img);

if nargin < 4
    method = 'bilinear';
end
if length(scaling) > 1
  scalingx = scaling(2)/size(img,2);
  scalingy = scaling(1)/size(img,1);
  if isnan(scalingx)
      scalingx = scalingy;
  end
  if isnan(scalingy)
      scalingy = scalingx;
  end
else
  scalingx = scaling;
  scalingy = scaling;
end
  
if scaling ~= 1
    if nargout > 1
      % Image resampling:
      %img = imresizefast(img, scaling, method);
      img = imresize(img, scaling, method);
    end
      
    % Change the size of the polygon coordinates
    if isfield(annotation, 'object')
        Nobjects = length(annotation.object); n=0;
        for i = 1:Nobjects
            [x,y] = getLMpolygon(annotation.object(i).polygon);
            x = round(x*scalingx);
            y = round(y*scalingy);
            annotation.object(i).polygon = setLMpolygon(x,y);
            
%             Npoints = length(annotation.object(i).polygon.pt);
%             for j = 1:Npoints
%                 % Scale each point:
%                 x=str2num(annotation.object(i).polygon.pt(j).x);
%                 y=str2num(annotation.object(i).polygon.pt(j).y);
% 
%                 x = round(x*scalingx);
%                 y = round(y*scalingy);
% 
%                 annotation.object(i).polygon.pt(j).x = num2str(x);
%                 annotation.object(i).polygon.pt(j).y = num2str(y);
%             end
        end
    end
end

% add/modify image size field
annotation.imagesize.nrows = size(img,1);
annotation.imagesize.ncols = size(img,2);

if nargout > 1
  % return the image in its original numeric format
  img = feval(imgtype.class, img);
end

function img = imresizefast(img, scaling, method, init)

if nargin<4
    init = 0;
end

if max(scaling) > .5
    img = imresize(img, scaling, method);
else
    c = size(img,3);
    for n = 1:c
        img(:,:,n) = conv2(img(:,:,n), [1 2 1; 2 4 2; 1 2 1]/16, 'same');
    end
    img = img(init+1:2:end, init+1:2:end, :);
    %img = convn(img, [1 2 1]/4, 'same'); 
    %img = img(:,init+1:2:end,:);
    img = imresizefast(img, 2*scaling, method, 1-init);
end



