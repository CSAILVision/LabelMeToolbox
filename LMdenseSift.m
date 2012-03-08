function [sift, SIFTparam] = LMdenseSift(D, HOMEIMAGES, SIFTparam, HOMESIFT)
%
% Computes dense SIFT features.
% The SIFT grid will be defined by the parameters:
%    SIFTparam.grid_spacing = 1; % distance between grid centers
%    SIFTparam.patch_size = 16;  % size of patch from which to compute SIFT
%    descriptor (it has to be a factor of 4)
%
% Run demoSIFT.m to see an example of how it works.
%
% The SIFT descriptor at each location has 128 dimensions.
%
% This function can be called as:
%
% [sift, param] = LMdenseSift(D(n), HOMEIMAGES, param);
% [sift, param] = LMdenseSift(filename, HOMEIMAGES, param);
% [sift, param] = LMdenseSift(filename, HOMEIMAGES, param, HOMESIFT);
% LMdenseSift(D, HOMEIMAGES, param, HOMESIFT);
%
% 'sift' corresponds to the features of the last image. So, call it passing
% just one image. But you can precompute the SIFT features for a set of
% images: When calling LMdenseSift with a fourth argument it will store the sift descriptors in a
% new folder structure mirroring the folder structure of the images. Then,
% when called again, if the sift files already exist, it will just read
% them without recomputing them.
%
% Antonio Torralba, 2008


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
    SIFTparam.grid_spacing = 1; % distance between grid centers
    SIFTparam.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
end
SIFTparam.w = SIFTparam.patch_size/2; % boundary
Nfeatures = 128;

if isstruct(D)
    % [gist, param] = LMdenseSift(D, HOMEIMAGES, param);
    Nscenes = length(D);
    typeD = 1;
end

if iscell(D)
    % [gist, param] = LMdenseSift(filename, HOMEIMAGES, param);
    Nscenes = length(D);
    typeD = 2;
end

if isnumeric(D)
    % [gist, param] = LMdenseSift(img, HOMEIMAGES, param);
    Nscenes = size(D,4);
    typeD = 3;
end

if Nscenes >1
    fig = figure;
end

% Loop: Compute SIFT features for all scenes
sift = zeros([Nscenes Nfeatures], 'single');
for n = 1:Nscenes
    g = [];
    todo = 1;
    
    % if SIFT has already been computed, just read the file
    if precomputed==1
        filesift = fullfile(HOMESIFT, D(n).annotation.folder, [D(n).annotation.filename(1:end-4) '.mat']);
        if exist(filesift, 'file')
            load(filesift, 'sift', 'SIFTparam');
            todo = 0;
        end
    end
    
    % otherwise compute SIFT
    if todo==1
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
        
        % get SIFT descriptors
        [sift, SIFTparam.grid_x, SIFTparam.grid_y] = dense_sift(img, SIFTparam);
        
        if isfield(SIFTparam, 'edges')
            % 'dont-compute': default if field not present
            % 'siftrepeat'
            w = SIFTparam.w-1;
            switch lower(SIFTparam.edges)
                case 'siftrepeat'
                    sift = [repmat(sift(1,:,:),[w 1 1]); sift; repmat(sift(end,:,:),[w 1 1])];
                    sift = [repmat(sift(:,1,:),[1 w 1]), sift, repmat(sift(:,end,:),[1 w 1])];
                otherwise
                    error('Unknown edges method')
            end
        end
        
        % save SIFT if a HOMESIFT file is provided
        if precomputed
            mkdir(fullfile(HOMESIFT, D(n).annotation.folder))
            save (filesift, 'sift', 'SIFTparam')
        end

        if Nscenes >1
            figure(fig);
            subplot(121)
            imshow(uint8(img))
            subplot(122)
            showColorSIFT(sift)
        end
    end

    drawnow
end




function [sift_arr, grid_x, grid_y] = dense_sift(I, SIFTparam)
% Original script by Svetlana Lazebnick
% Antonio Torralba: modified using convolutions to speed up the
% computations.

grid_spacing = SIFTparam.grid_spacing;
patch_size = SIFTparam.patch_size;

I = double(I);
I = mean(I,3);
I = I /max(I(:));

% parameters
num_angles = 8;
num_bins = 4;
num_samples = num_bins * num_bins;
alpha = 9; %% parameter for attenuation of angles (must be odd)

if nargin < 5
    sigma_edge = 1;
end

angle_step = 2 * pi / num_angles;
angles = 0:angle_step:2*pi;
angles(num_angles+1) = []; % bin centers

[hgt wid] = size(I);

[G_X,G_Y]=gen_dgauss(sigma_edge);

% add boundary:
I = [I(2:-1:1,:,:); I; I(end:-1:end-1,:,:)];
I = [I(:,2:-1:1,:) I I(:,end:-1:end-1,:)];

I = I-mean(I(:));
I_X = filter2(G_X, I, 'same'); % vertical edges
I_Y = filter2(G_Y, I, 'same'); % horizontal edges

I_X = I_X(3:end-2,3:end-2,:);
I_Y = I_Y(3:end-2,3:end-2,:);

I_mag = sqrt(I_X.^2 + I_Y.^2); % gradient magnitude
I_theta = atan2(I_Y,I_X);
I_theta(find(isnan(I_theta))) = 0; % necessary????

% grid 
grid_x = patch_size/2:grid_spacing:wid-patch_size/2+1;
grid_y = patch_size/2:grid_spacing:hgt-patch_size/2+1;

% make orientation images
I_orientation = zeros([hgt, wid, num_angles], 'single');

% for each histogram angle
cosI = cos(I_theta);
sinI = sin(I_theta);
for a=1:num_angles
    % compute each orientation channel
    tmp = (cosI*cos(angles(a))+sinI*sin(angles(a))).^alpha;
    tmp = tmp .* (tmp > 0);

    % weight by magnitude
    I_orientation(:,:,a) = tmp .* I_mag;
end

% Convolution formulation:
weight_kernel = zeros(patch_size,patch_size);
r = patch_size/2;
cx = r - 0.5;
sample_res = patch_size/num_bins;
weight_x = abs((1:patch_size) - cx)/sample_res;
weight_x = (1 - weight_x) .* (weight_x <= 1);

for a = 1:num_angles
    %I_orientation(:,:,a) = conv2(I_orientation(:,:,a), weight_kernel, 'same');
    I_orientation(:,:,a) = conv2(weight_x, weight_x', I_orientation(:,:,a), 'same');
end

% Sample SIFT bins at valid locations (without boundary artifacts)
% find coordinates of sample points (bin centers)
[sample_x, sample_y] = meshgrid(linspace(1,patch_size+1,num_bins+1));
sample_x = sample_x(1:num_bins,1:num_bins); sample_x = sample_x(:)-patch_size/2;
sample_y = sample_y(1:num_bins,1:num_bins); sample_y = sample_y(:)-patch_size/2;

sift_arr = zeros([length(grid_y) length(grid_x) num_angles*num_bins*num_bins], 'single');
b = 0;
for n = 1:num_bins*num_bins
    sift_arr(:,:,b+1:b+num_angles) = I_orientation(grid_y+sample_y(n), grid_x+sample_x(n), :);
    b = b+num_angles;
end
clear I_orientation


% Outputs:
[grid_x,grid_y] = meshgrid(grid_x, grid_y);
[nrows, ncols, cols] = size(sift_arr);

% normalize SIFT descriptors

%sift_arr = reshape(sift_arr, [nrows*ncols num_angles*num_bins*num_bins]);
%sift_arr = normalize_sift(sift_arr);
%sift_arr = reshape(sift_arr, [nrows ncols num_angles*num_bins*num_bins]);


ct = .1;
sift_arr = sift_arr + ct;
tmp = sqrt(sum(sift_arr.^2, 3));
sift_arr = sift_arr ./ repmat(tmp, [1 1 size(sift_arr,3)]);

function [GX,GY]=gen_dgauss(sigma)

% laplacian of size sigma
%f_wid = 4 * floor(sigma);
%G = normpdf(-f_wid:f_wid,0,sigma);
%G = G' * G;
G = gen_gauss(sigma);
[GX,GY] = gradient(G); 

GX = GX * 2 ./ sum(sum(abs(GX)));
GY = GY * 2 ./ sum(sum(abs(GY)));


function G=gen_gauss(sigma)

if all(size(sigma)==[1, 1])
    % isotropic gaussian
	f_wid = 4 * ceil(sigma) + 1;
    G = fspecial('gaussian', f_wid, sigma);
%	G = normpdf(-f_wid:f_wid,0,sigma);
%	G = G' * G;
else
    % anisotropic gaussian
    f_wid_x = 2 * ceil(sigma(1)) + 1;
    f_wid_y = 2 * ceil(sigma(2)) + 1;
    G_x = normpdf(-f_wid_x:f_wid_x,0,sigma(1));
    G_y = normpdf(-f_wid_y:f_wid_y,0,sigma(2));
    G = G_y' * G_x;
end





