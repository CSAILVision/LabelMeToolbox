close all

% Train estimation of camera parameters
trainingfile = 'streets_general_camera_training.mat'
outputfile   = 'streets_general_camera_parameters.mat'
HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations'
HOMEIMAGES = 'http://labelme.csail.mit.edu/Images'

% Read index
D = LMdatabase(HOMEANNOTATIONS);
D = LMquery(D, 'scenedescription', 'street');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COLLECT TRAINING
% Show images and click on the locations of heads in the image
if exist(trainingfile, 'file')
    load (trainingfile)
    m = length(hor.imname);
else
    m=0; 
    hor.imname=[];
    hor.horizon=[];
end

for n = 1:length(D)
    file = fullfile(D(n).annotation.folder, D(n).annotation.filename);
    if ~ismember(file, hor.imname)
        img = LMimread(D, n, HOMEIMAGES);

        horizon = getHorizon(img, 'user');

        m = m+1
        hor.imname{m} = file;
        hor.horizon(m) = horizon;
        hor.D(m) = D(n);

        save (trainingfile, 'hor');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRAIN REGRESSOR

% Parameters GIST
GISTparam.imageSize = 128;
GISTparam.orientationsPerScale = [8 8 8 8];
GISTparam.numberBlocks = 4;
GISTparam.fc_prefilt = 4;

% Parameters regression 
paramHor.NgF=4; 
paramHor.npca=32; 
paramHor.SigmaX=.1; 
paramHor.iterF=25; 

% Compute gist for training images
[gist, param] = LMgist(hor.D, HOMEIMAGES, GISTparam);
gist = gist ./ repmat(sqrt(sum(gist.^2,1)),[size(gist,1) 1]);
paramHor.A = pca(gist', paramHor.npca);

% Train regressor on valid images
valid = find(hor.horizon>-.5 & hor.horizon<.5);
Nsamples = length(valid);

j = randperm(Nsamples); 
j = valid(j(1:round(Nsamples*.9)));
[fv,paramHor.py,paramHor.mgy,paramHor.Cgy,paramHor.Cy,paramHor.by] = ...
    CWM(hor.horizon(j), double(gist(j,:)*paramHor.A)', paramHor.NgF, paramHor.iterF, 1, paramHor.SigmaX);

save(outputfile, 'paramHor', 'GISTparam')

% Validation
v = setdiff(valid, j);
clear my Sy
for t = 1:length(v)
    img = LMimread(hor.D, v(t), HOMEIMAGES);
    my(t) = getHorizon(img, 'gist');
    
    [nrows ncols cc] = size(img);
    figure(1)
    hold off
    imshow(img)
    hold on
    plot([1 ncols], ([my(t) my(t)]+.5)*nrows, 'b', 'linewidth',3);
    plot([1 ncols], ([hor.horizon(v(t)) hor.horizon(v(t))]+.5)*nrows,'r');
    title(my(t))
    drawnow
end

figure
plot(hor.horizon(v), my, '.')
hold on
plot([-.5 .5], [-.5 .5],'g')
axis('equal')

