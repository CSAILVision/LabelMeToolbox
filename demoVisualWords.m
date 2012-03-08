% demo SIFT/hog+visual words using LabelMe toolbox
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIFT parameters:
%VWparam.imagesize = 256; % normalized image size (images will be scaled so that the maximal axis has this dimension before computing the sift features)
VWparam.grid_spacing = 1; % distance between grid centers
VWparam.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
VWparam.NumVisualWords = 200; % number of visual words
VWparam.Mw = 2; % number of spatial scales for spatial pyramid histogram
%VWparam.descriptor = 'sift'; % number of spatial scales for spatial pyramid histogram
VWparam.descriptor = 'hog'; % Descriptor type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTANTS (you can not change this)
switch VWparam.descriptor
    case 'sift'
        w = VWparam.patch_size/2; % boundary for SIFT
    case 'hog'
        w = floor(VWparam.patch_size/2*2.5); % boundary for HOG
end


% read database struct
HOMEIMAGES = '/Users/torralba/atb/Databases/15scenes'

D = LMdatabase(HOMEIMAGES, HOMEIMAGES);

% Build dictionary of visual words
VWparam = LMkmeansVisualWords(D(1:20:end), HOMEIMAGES, VWparam);

% COMPUTE VISUAL WORDS: 
[VW, sptHist] = LMdenseVisualWords(D(1:10), HOMEIMAGES, VWparam);

% Visualization
img = LMimread(D,1,HOMEIMAGES);

figure
subplot(121)
imshow(img)
axis('on')
subplot(122)
imagesc(VW(:,:,1))
axis('equal')
axis('tight')
axis('on')
