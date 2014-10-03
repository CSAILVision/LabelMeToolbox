function h = getHorizon(img, method)
% 
% The goal is to estimate the location of the horizon line on an image. 
%    h = getHorizon(img, method);
%
% Input:
%    img = image
%    method = 'gist', 'user'
%
% Output:
%    h = location of the horizon line. Distance to the center of the
%        image (normalized units with respect to image height).
%    h is a value in the range [-0.5, 0.5]
%
% Example:
%    h = getHorizon(img);
%    [nrows ncols cc] = size(img);
%    figure
%    imshow(img)
%    hold on
%    plot([1 ncols], ([h h]+.5)*nrows, 'b', 'linewidth',3);
%
% This function uses the approach described in:
% 
% - A. Torralba, P. Sinha. Statistical context priming for object detection. ICCV 2001.
% - D. Hoiem, Seeing the World Behind the Image: Spatial Layout for 3D Scene Understanding, CMU doctoral dissertation 2007.
% - J. Sivic, B. Kaneva, A. Torralba, S. Avidan and W. T. Freeman. Creating and exploring a large photorealistic virtual space. Workshop on Internet Vision, 2008.
%

% A Torralba, 2008

if nargin == 1
    method = 'gist';
end

[nrows ncols cc] = size(img);

switch method
    case 'user'
        figH = figure;
        imshow(uint8(img))
        title('Click on the horizon line')
        [x,y] = ginput(1);
        
        h = y/nrows - 0.5;
        close(figH)
        
    case 'gist'
        paramfile = 'streets_general_camera_parameters.mat';
        % load regresor parameters (param)
        load (paramfile);
        
        % compute gist from current image
        gist = LMgist(img, [], GISTparam);

        % estimate location horizon line
        gist = gist ./ sqrt(sum(gist.^2));
        h = maxCWM((gist*paramHor.A)', paramHor.py, paramHor.mgy, paramHor.Cgy, paramHor.Cy, paramHor.by);
end



