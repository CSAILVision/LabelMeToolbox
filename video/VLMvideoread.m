function [video, annotation] = VLMvideoread(varargin)
% Visualizes the polygons in an image.
%
% LMvideoread(D, ndx, HOMEVIDEOS)
% LMvideoread(D, ndx, frames, HOMEVIDEOS)
% LMvideoread(annotationfilename, videofilename)
% LMvideoread(videofilename)
%

frames = [];
clear frames

switch length(varargin)
    case 1
        videofilename = varargin{1};
    case 2
        annotationfilename = varargin{1};
        videofilename = varargin{2};
        if strcmp(videofilename(end-3), '.')
            videofilename = videofilename(1:end-4);
        end

        if nargout > 1
            % read annotation only if requested
            v = loadXML(annotationfilename);
            v = LMvalidobjects(v);
            annotation = v.annotation;            
        else
            annotation = [];
        end
    case 3
        % LMvideoread(D, ndx, HOMEVIDEOS)
        D = varargin{1};
        ndx = varargin{2};
        if ndx>length(D)
            error('Index outside database range')
        end
        HOMEVIDEOS = varargin{3};
        annotation = D(ndx).annotation;
        videofilename = fullfile(HOMEVIDEOS, annotation.folder, annotation.filename(1:end-4));
    case 4
        % LMvideoread(D, ndx, frames, HOMEVIDEOS)
        D = varargin{1};
        ndx = varargin{2};
        if ndx>length(D)
            error('Index outside database range')
        end
        frames = varargin{3};
        HOMEVIDEOS = varargin{4};
        annotation = D(ndx).annotation;
        videofilename = fullfile(HOMEVIDEOS, annotation.folder, annotation.filename(1:end-4));
    otherwise
        error('Too many input arguments.')
end

% Open video object
files = dir(fullfile(videofilename, '*.jpg'));
files = sort({files(:).name});
numFrames = length(files);
if isempty(frames)
    frames = 1:numFrames;
end


% Read video
frame1 = imread(fullfile(videofilename, files{frames(1)}));
[nrows, ncols, cc] = size(frame1);
video = zeros([nrows ncols 3 length(frames)], 'uint8');
video (:,:,:,1) = frame1;
for f = 2:length(frames)
    video(:,:,:,f) = imread(fullfile(videofilename, files{frames(f)}));
end
     


