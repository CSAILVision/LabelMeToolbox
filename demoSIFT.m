% demo SIFT using LabelMe toolbox

img = imread('demo1.jpg');
img = imresize(img, .5, 'bilinear');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIFT parameters:
SIFTparam.grid_spacing = 1; % distance between grid centers
SIFTparam.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTANTS (you can not change this)
w = SIFTparam.patch_size/2; % boundary 

% COMPUTE SIFT: the output is a matrix [nrows x ncols x 128]
tic; 
SIFT = LMdenseSift(img, '', SIFTparam); 
toc

figure
subplot(121)
imshow(img(w:end-w+1,w:end-w+1,:))
title('cropped image')
subplot(122)
showColorSIFT(SIFT)
title('SIFT color coded')
