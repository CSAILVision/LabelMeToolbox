function [VW, sptHist] = LMdenseVisualWords(D, HOMEIMAGES, VWparam)
%
% Compute dense visual words and spatial pyramid histogram.
%
% The SIFT grid + visual words will be defined by the parameters VWparam:
%   VWparam.imagesize = 256; % normalized image size (images will be scaled so that the maximal axis has this dimension before computing the sift features)
%   VWparam.grid_spacing = 1; % distance between grid centers
%   VWparam.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
%   VWparam.NumVisualWords = 200; % number of visual words
%   VWparam.Mw = 2; % number of spatial scales for spatial pyramid histogram
%
% Run demoVisualWords.m to see an example of how it works.
%
% The SIFT descriptor at each location has 128 dimensions and is vector quantized.
%
% This function can be called as:
%
% [VW, sptHist] = LMdenseVisualWords(img, HOMEIMAGES, param);
% [VW, sptHist] = LMdenseVisualWords(D(n), HOMEIMAGES, param);
% [VW, sptHist] = LMdenseVisualWords(filename, HOMEIMAGES, param);
%
%
% Antonio Torralba, 2008

if ~isfield(VWparam, 'descriptor')
    VWparam.descriptor = 'sift';
end

if isfield(VWparam, 'imageSize')
    VWparam.imagesize = VWparam.imageSize;
end

if isfield(VWparam, 'storewords')
    storewords = VWparam.storewords;
else
    storewords = 1;
end

if isfield(VWparam, 'imagesize')
    if length(VWparam.imagesize)==1
        VWparam.imagesize = [1 1]*VWparam.imagesize;
    end
end

if nargin==4
    precomputed = 1;
    % get list of folders and create non-existing ones
    %listoffolders = {D(:).annotation.folder};
else
    precomputed = 0;
    HOMESIFT = '';
end

if nargin<3
    % Default parameters
    VWparam.grid_spacing = 1; % distance between grid centers
    VWparam.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
end

switch VWparam.descriptor
    case 'sift'
        Nfeatures = 128;
        w = VWparam.patch_size-2; % boundary for SIFT
    case 'hog'
        Nfeatures = 124;
        w = floor(VWparam.patch_size/2*2.5)*2; % boundary for HOG
end


if isstruct(D)
    % [gist, param] = LMdenseVisualWords(D, HOMEIMAGES, param);
    Nscenes = length(D);
    typeD = 1;
end
if iscell(D)
    % [gist, param] = LMdenseVisualWords(filename, HOMEIMAGES, param);
    Nscenes = length(D);
    typeD = 2;
end
if isnumeric(D)
    % [gist, param] = LMdenseVisualWords(img, HOMEIMAGES, param);
    Nscenes = size(D,4);
    typeD = 3;
end

if Nscenes >1
    fig = figure;
end

% Loop: Compute visual words for all scenes
if storewords==1
    if isfield(VWparam, 'imagesize')
        n = VWparam.imagesize(1)-w;
        m = VWparam.imagesize(2)-w;
    else
        % read one image to check size. This will only work if all the images
        % have the same size
        switch typeD
            case 1
                img = LMimread(D, 1, HOMEIMAGES);
            case 2
                img = imread(fullfile(HOMEIMAGES, D{1}));
            case 3
                img = D(:,:,:,1);
        end
        n = size(img,1)-w;
        m = size(img,2)-w;
    end
    
    if VWparam.NumVisualWords<256
        VW = zeros([n m Nscenes], 'uint8');
    else
        VW = zeros([n m Nscenes], 'uint16');
    end
else
    VW= [];
end

sptHist = zeros([VWparam.NumVisualWords*((4^VWparam.Mw-1)/3) Nscenes], 'single');
for n = 1:Nscenes
    g = [];
    todo = 1;
    % otherwise compute gist
    if todo==1
        if Nscenes>1
            disp([n Nscenes])
        end

        % load image
        try
            switch typeD
                case 1
                    img = LMimread(D, n, HOMEIMAGES);
                case 2
                    img = imread(fullfile(HOMEIMAGES, D{n}));
                case 3
                    img = D(:,:,:,n);
            end
        catch
            disp(D(n).annotation.folder)
            disp(D(n).annotation.filename)
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

        % get  descriptors
        switch VWparam.descriptor
            case 'sift'
                v = LMdenseSift(img, HOMEIMAGES, VWparam);
            case 'hog'
                v = dense_hog2x2(img, VWparam);
                
        end

        %sift = single(LMdenseSift(img, HOMEIMAGES, VWparam));
        [nrows ncols nf] = size(v);
        v = reshape(v, [size(v,1)*size(v,2) Nfeatures]);
        
        % vector quantization
        [fitd, w] = min(distMat(single(VWparam.visualwordcenters), v));
        w = reshape(w, [nrows ncols]);
        
        if storewords==1
            if VWparam.NumVisualWords<256
                VW(:,:,n) = uint8(w);
            else
                VW(:,:,n) = uint16(w);
            end
        end

        % Compute spatial histogram
        sptHist(:,n) = single(spatialHistogram(w, VWparam.Mw, VWparam.NumVisualWords));
        
        
        if Nscenes >1
            figure(fig);
            subplot(121)
            imshow(uint8(img))
            subplot(122)
            imagesc(w)
            axis('equal')
            axis('off')
        end
    end

    drawnow
end




function D=distMat(P1, P2)
%
% Euclidian distances between vectors

if nargin == 2
    X1=repmat(single(sum(P1.^2,2)),[1 size(P2,1)]);
    X2=repmat(single(sum(P2.^2,2)),[1 size(P1,1)]);
    R=P1*P2';
    D=X1+X2'-2*R;
else
    % each vector is one column
    X1=repmat(sum(P1.^2,1),[size(P1,2) 1]);
    R=P1'*P1;
    D=X1+X1'-2*R;
    D = sqrt(D);
end



function h = spatialHistogram(W, Mw, Nwords)
% Mw = number of spatial windows for computing histograms
coef = 1./[2^(Mw-1) 2.^(Mw-(1:(Mw-1)))];

h = [];
for M = 1:Mw
    lx = round(linspace(1, size(W,2)-1, 2^(M-1)+1));
    ly = round(linspace(1, size(W,1)-1, 2^(M-1)+1));
    for x = 1:2^(M-1)
        for y = 1:2^(M-1)
            ww = W(ly(y)+1:ly(y+1), lx(x)+1:lx(x+1));
            hh = hist(ww(:), 1:Nwords);
            h = [h coef(M)*hh];
        end
    end
end

% store words
h = h /sum(h);




























