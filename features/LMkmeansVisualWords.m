function VWparam = LMkmeansVisualWords(D, HOMEIMAGES, VWparam)
%
% VWparam = LMkmeansVisualWords(D, HOMEIMAGES, VWparam);
% VWparam = LMkmeansVisualWords(filenames, HOMEIMAGES, VWparam);
% VWparam = LMkmeansVisualWords(img, HOMEIMAGES, VWparam);
%
% Build dictionary of visual words
%   VWparam = LMkmeansVisualWords(D, HOMEIMAGES, VWparam);
%
% Compute visual words
%   [VW, sptHist] = LMdenseVisualWords(D(1:10), HOMEIMAGES, VWparam);
%
% PARAMETERS:
% VWparam.imagesize = 640; % normalized image size (images will be scaled
%   so that the maximal axis has this dimension before computing the sift
%   features). If this parameter is not specified, the image will not be
%   rescaled.
% VWparam.grid_spacing = 1; % distance between grid centers
% VWparam.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
% VWparam.NumVisualWords = 500; % number of visual words
% VWparam.Mw = 2; % number of spatial scales for spatial pyramid histogram

if ~isfield(VWparam, 'descriptor')
    VWparam.descriptor = 'sift';
end

if isfield(VWparam, 'imageSize')
    VWparam.imagesize = VWparam.imageSize;
end

if isstruct(D)
    % [gist, param] = LMdenseVisualWords(D, HOMEIMAGES, param);
    Nimages = length(D);
    typeD = 1;
end
if iscell(D)
    % [gist, param] = LMdenseVisualWords(filename, HOMEIMAGES, param);
    Nimages = length(D);
    typeD = 2;
end
if isnumeric(D)
    % [gist, param] = LMdenseVisualWords(img, HOMEIMAGES, param);
    Nimages = size(D,4);
    typeD = 3;
end

switch VWparam.descriptor
    case 'sift'
        Nfeatures = 128;
    case 'hog'
        Nfeatures = 124;
end

Nsamples = 20;

% Extract a sample of SIFT features to compute the visual word centers
P = zeros([Nimages*Nsamples Nfeatures], 'single');
k = 0;
for i = 1:Nimages
    Nimages - i
    % load image and reshape to standard format
    % load image
    try
        switch typeD
            case 1
                img = LMimread(D, i, HOMEIMAGES);
            case 2
                img = imread(fullfile(HOMEIMAGES, D{i}));
            case 3
                img = D(:,:,:,i);
        end
    catch
        disp(D(i).annotation.folder)
        disp(D(i).annotation.filename)
        rethrow(lasterror)
    end

    % Reshape image to standard format
    if isfield(VWparam, 'imagesize')
        img = imresizecrop(img, VWparam.imagesize, 'bilinear');
    end

    %M = max(size(img,1), size(img,2));
    %if M~=VWparam.imagesize
    %    img = imresize(img, VWparam.imagesize/M, 'bilinear');
    %end
    
    switch VWparam.descriptor
        case 'sift'
            v = LMdenseSift(img, HOMEIMAGES, VWparam);
        case 'hog'
            v = dense_hog2x2(img, VWparam); 
            
    end
    v = reshape(v, [size(v,1)*size(v,2) Nfeatures]);
                
    n = size(v,1);
    r = randperm(n); r = r(1:Nsamples);
    
    P(k+1:k+Nsamples,:) = v(r,:);
    k = k + Nsamples;
end

% Apply K-means to the SIFT vectors.
disp('Kmeans')
[IDX, Centers] = kmeans(P, VWparam.NumVisualWords, 'display', 'iter', 'Maxiter', 800, 'EmptyAction', 'singleton'); %returns the k cluster centroid locations in the k-by-p matrix C.

% Sort centers using the first principal component:
[foo, pc, latent] = pca(P', 2);
pc1 = pc(:,1)'*Centers';
[foo,k] = sort(pc1);
Centers = Centers(k,:);

% Store results in param struct
VWparam.visualwordcenters = Centers;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [feat, pc, latent, mu] = pca(features, N)
% features: one vector per column

mu = mean(features, 2);
fm = features - repmat(mu, 1, size(features,2));
X  = fm*fm'; 

[pc, latent] = eigs(double(X), N);
feat = (pc' * features);
