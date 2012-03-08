%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Video LabelMe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% change path:
HOMEVIDEOFRAMES = 'http://labelme.csail.mit.edu/VideoLabelMe/VLMFrames/';
HOMEVIDEOANNOTATIONS = 'http://labelme.csail.mit.edu/VideoLabelMe/VLMAnnotations/';

%HOMEVIDEOFRAMES = '/afs/csail.mit.edu/group/vision/www/data/LabelMe/VideoLabelMe/VLMFrames/';
%HOMEVIDEOANNOTATIONS = '/afs/csail.mit.edu/group/vision/www/data/LabelMe/VideoLabelMe/VLMAnnotations/';

% read list of folders
folder = folderlist(HOMEVIDEOANNOTATIONS, 'videos_iccv09');

% Create video index
D = LMdatabase(HOMEVIDEOANNOTATIONS, folder);

% play first movie
VLMplay(D, 1, HOMEVIDEOFRAMES)

% Load first 10 frames
video = VLMvideoread(D, 1, 1:10, HOMEVIDEOFRAMES);




