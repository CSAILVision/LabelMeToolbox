% demo HOG using LabelMe toolbox
%
% The HOG code is modified by Jianxiong Xiao, based on the HOG implementation from object detector written by
% P. Felzenszwalb, R. Girshick, D. McAllester, D. Ramanan at http://people.cs.uchicago.edu/~pff/latent/ .
%
% Before using HOG, follow the compilation instructions inside pixelwise_hog31.cc

img = imread('demo1.jpg');
%img = imresize(img, .5, 'bilinear');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SIFT parameters:
HOG2x2param.grid_spacing = 1; % distance between grid centers
HOG2x2param.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CONSTANTS (you can not change this)
w = floor(HOG2x2param.patch_size/2*2.5); % boundary 

% COMPUTE SIFT: the output is a matrix [nrows x ncols x 128]
tic; 
HOG = dense_hog2x2(img, HOG2x2param); 
toc

figure
subplot(121)
imshow(img(w:end-w+1,w:end-w+1,:))
axis('on')
title('cropped image')
subplot(122)
imshow(HOG(:,:,1:3))
axis('on')
title('HOG color coded')
