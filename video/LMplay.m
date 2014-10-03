function [video, map] = LMplay(varargin)
% Visualizes the polygons from a video using a .
%
% To play the annotations only:
% LMplay(annotation)
%
% To get video for selected frames
% LMplay(D, ndx, HOMEVIDEOS, frameSkipRate)

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


d = dir(fullfile(videoFramesPath, '*.jpg'));%str2num(annotation.numFrames);
numFrames = length(d);
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
set(gcf, 'position', [183   712   202   167]);
video =[];
k = 1;
rootName = annotation.filename(1:end-4);

for f = 1:frameSkipRate:numFrames
    if ~isempty(videoFramesPath)
        filename = fullfile(videoFramesPath, sprintf('%s_%05d.jpg', rootName, f));
        if strcmp(filename(1:5), 'http:')
            filename = strrep(filename, '\', '/');
            filename = strrep(filename, '%20', ' '); % replace space character
        else
            filename = strrep(filename, '/', filesep);
            filename = strrep(filename, '\', filesep);
        end

        frame = imread(filename);

        %frame = imread(fullfile(videoFramesPath, videoDir(f).name));
    else
        frame = zeros([480 640 3], 'uint8');
    end
    hold off; clf
    image(uint8(frame));
   % title(sprintf('frame: %d/%d', f, numFrames))
    axis('off'); axis('equal'); 
    hold on

    [nrows ncols cc] = size(frame);
    
    % Draw each object (only non deleted ones)
    if isfield(annotation, 'object')
        Nobjects = length(annotation.object); n=0;
        for i = Nobjects:-1:1
            n = n+1;
            class{n} = annotation.object(i).name; % get object name
            col = colors(mod(sum(double(class{n})),15)+1, :);
            %[X,Y,t] = getLMpolygon(annotation.object(i).polygon);
            [X,Y,jc,t] = LMobjectpolygon(annotation, i);

            LineWidth = 4;
            i = find(t==f);
            if ~isempty(i)
                plot([X(:,i); X(1,i)],[Y(:,i); Y(1,i)], 'LineWidth', LineWidth, 'color', [0 0 0]); hold on
                plot([X(:,i); X(1,i)],[Y(:,i); Y(1,i)], 'LineWidth', LineWidth/2, 'color', col);
                hold on
            end
        end
    end
    axis([1 ncols 1 nrows])
    drawnow
    
    if(exist('destRoot', 'var'))
        print( '-dpsc2', sprintf('%s_%04d.eps', destRoot, f));
    end
    if k ==1
        gf = getframe;
        fr = gf.cdata;
        %fr = imresize(fr, .25, 'bilinear');
        video = zeros([size(fr,1) size(fr,2) 1 numFrames/frameSkipRate], 'uint8');
        [video(:,:,1,k), map] = rgb2ind(fr,.14);
    else
        gf = getframe;
        fr = gf.cdata;
        %fr = imresize(fr, .25, 'bilinear');
        fr = uint8(single(fr*.99));
        [video(:,:,1,k) map] = rgb2ind(fr, map);
    end
    k = k + 1;
end

