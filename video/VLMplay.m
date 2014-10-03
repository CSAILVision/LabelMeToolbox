function VLMplay(varargin)
% Visualizes the polygons from a video and the tracks if available inside the annotation.
%
% To play the annotations only:
% VLMplay(annotation)
%
% To get video for selected frames
% VLMplay(D, ndx, HOMEVIDEOS, frameSkipRate)

switch length(varargin)
    case 1
        v = varargin{1};
        annotation = v.annotation;
        videoFramesPath = '';
        
    case 3
        D = varargin{1};
        ndx = varargin{2};
        
        if ndx>length(D)
            error('Index outside database range')
        end
        
        HOMEVIDEOS = varargin{3};
        
        annotation = D(ndx).annotation;
        videoFramesPath = fullfile(HOMEVIDEOS, annotation.folder, annotation.filename(1:end-4));
        
    case 4
        D = varargin{1};
        ndx = varargin{2};
        if ndx>length(D)
            error('Index outside database range')
        end
        
        HOMEVIDEOS = varargin{3};
        
        annotation = D(ndx).annotation;
        videoFramesPath = fullfile(HOMEVIDEOS, annotation.folder, annotation.filename(1:end-4));
        frameSkipRate = varargin{4};
        
    otherwise
        error('wrong number of input arguments.')
end

numFrames = str2num(annotation.numFrames);
% Define colors
colors = hsv(15);

if ~isempty(videoFramesPath)
    % Open the directory containing the frames
    videoDir = dir(fullfile(videoFramesPath, '*.jpg'));
end

%default if frameIdxs is not given
if(~exist('frameSkipRate', 'var'))
    frameSkipRate = 1;
end

% Draw image
figure(1);
% if we want to resize, uncomment the next line:
%set(gcf, 'position', [183   712   202   167]);
rootName = annotation.filename(1:end-4);

for f = 1:frameSkipRate:numFrames
    [annotation, frame] = VLMgetvideoframe(D(ndx).annotation, f, HOMEVIDEOS);    
    [nrows ncols cc] = size(frame);
    hold off; 
    LMplot(annotation, frame)
    
    hold on
    plot([annotation.tracks.track.x], [annotation.tracks.track.y], 'o', 'MarkerFaceColor','r', 'MarkerEdgeColor','y', 'MarkerSize', 5)

    axis([1 ncols 1 nrows])
    drawnow
end

