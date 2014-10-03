function [tinyImage, colorHist, param] = LMcolor(D, HOMEIMAGES, param)
%
% [tinyImage, colorHist, param] = LMcolor(D, HOMEIMAGES, param);
%
% param.tinySize
% param.colorHist.imagesize
% param.colotHist.
%
% Use transformations from "color indexing", Swain & Ballard, IJCV 91
%
%   wb = (r+g+b)/3
%   rg = r - g
%   by = b-r/2-g/2


if nargin<3
    % Default parameters
    param.tinySize = [16 16];
    param.colorHist.imagesize = [256 256];
    param.colorHist.nbins = [8 16 16];
    param.colorHist.margins.wb = [0 255];
    param.colorHist.margins.rg = [-255 255];
    param.colorHist.margins.by = [-255 255];
end

% Precompute filter transfert functions (only need to do this once, unless
% image size is changes):
Nfeatures = prod(param.colorHist.nbins);

if isstruct(D)
    % [gist, param] = LMcolor(D, HOMEIMAGES, param);
    Nscenes = length(D);
    typeD = 1;
end
if iscell(D)
    % [gist, param] = LMcolor(filename, HOMEIMAGES, param);
    Nscenes = length(D);
    typeD = 2;
end
if isnumeric(D)
    % [gist, param] = LMcolor(img, HOMEIMAGES, param);
    Nscenes = size(D,4);
    typeD = 3;
end

% Loop: Compute gist features for all scenes
tinyImage = zeros([param.tinySize 3 Nscenes], 'single');
colorHist = zeros([Nscenes Nfeatures], 'single');
for n = 1:Nscenes
    disp([n Nscenes])
    
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
    
    % resize and crop image to make it square
    tiny = imresizecrop(img, param.tinySize+2, 'bilinear');
    tinyImage(:,:,:,n) = tiny(2:end-1, 2:end-1,:);
    
    subplot(211)
    imagesc(img); axis('off'); axis('equal')
    subplot(212)
    imagesc(tiny); axis('on'); axis('equal')
    
    % resize and crop image to make it square
    img = single(imresizecrop(img, param.imagesize, 'bilinear'));
    
    %   wb = (r+g+b)/3
    %   rg = r - g
    %   by = b-r/2-g/2
    wb = mean(img,3);
    rg = img(:,:,1)-img(:,:,2);
    by = img(:,:,3)-img(:,:,1)/2-img(:,:,2)/2;
    
    wb = (wb(:)-param.colorHist.margins.wb(1))/(param.colorHist.margins.wb(2)-param.colorHist.margins.wb(1));
    rg = (rg(:)-param.colorHist.margins.rg(1))/(param.colorHist.margins.rg(2)-param.colorHist.margins.rg(1));
    by = (by(:)-param.colorHist.margins.by(1))/(param.colorHist.margins.by(2)-param.colorHist.margins.by(1));
    
    wb = fix(wb*param.colorHist.nbins(1));
    rg = fix(rg*param.colorHist.nbins(2));
    by = fix(by*param.colorHist.nbins(3));
    
    wb = min(max(0,wb), param.colorHist.nbins(1)-1);
    rg = min(max(0,rg), param.colorHist.nbins(2)-1);
    by = min(max(0,by), param.colorHist.nbins(3)-1);
    
    h = by + rg*param.colorHist.nbins(3) + wb*param.colorHist.nbins(3)*param.colorHist.nbins(2);
    H = hist(h, [0:Nfeatures-1]);
    
    % store
    colorHist(n,:) = H;
    drawnow
end

