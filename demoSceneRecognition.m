% Scene recognition
%
% This script trains a SVM to classify 8 scene categories.

addpath('/Users/torralba/atb/MatlabTools/primalSVM')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
HOMEIMAGES = '/Users/torralba/atb/TALKS/2010_seminario_UC3M/day 4/laboratorio/scenes'; % each category has to be in a separate folder

% build index database
D = LMdatabase(HOMEIMAGES, HOMEIMAGES); % build index
%D = D(1:2:end); % for speed, we will reduce the number of images. But you can remove this line.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 1:  Compute global descriptors.

% gist Parameters:
clear GISTparam
GISTparam.imageSize = [256 256]; % it works also with non-square images
GISTparam.orientationsPerScale = [8 8 8 8];
GISTparam.numberBlocks = 4;
GISTparam.fc_prefilt = 4;
% compute gist for all images in the database
[gist, GISTparam] = LMgist(D, HOMEIMAGES, GISTparam);

% SIFT visual words
clear VWparamsift
VWparamsift.imageSize = [256 256]; % it works also with non-square images
VWparamsift.grid_spacing = 1; % distance between grid centers
VWparamsift.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
VWparamsift.NumVisualWords = 200; % number of visual words
VWparamsift.Mw = 2; % number of spatial scales for spatial pyramid histogram
VWparamsift.descriptor = 'sift';
VWparamsift.w = VWparamsift.patch_size/2; % boundary for SIFT

% Build dictionary of visual words
VWparamsift = LMkmeansVisualWords(D(1:10:end), HOMEIMAGES, VWparamsift);

% Compute visual words:
[VWsift, sptHistsift] = LMdenseVisualWords(D, HOMEIMAGES, VWparamsift);
sptHistsift = sptHistsift';

% HOG visual words
clear VWparamhog
VWparamhog.imageSize = [256 256]; % it works also with non-square images
VWparamhog.grid_spacing = 1; % distance between grid centers
VWparamhog.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
VWparamhog.NumVisualWords = 200; % number of visual words
VWparamhog.Mw = 2; % number of spatial scales for spatial pyramid histogram
VWparamhog.descriptor = 'hog';
VWparamhog.w = floor(VWparamhog.patch_size/2*2.5); % boundary for HOG

% Build dictionary of visual words
VWparamhog = LMkmeansVisualWords(D(1:10:end), HOMEIMAGES, VWparamhog);

% Compute visual words:
[VWhog, sptHisthog] = LMdenseVisualWords(D, HOMEIMAGES, VWparamhog);
sptHisthog = sptHisthog';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 2: Scene recognition
% get classes
[class, categories] = folder2class(D);

% split training/validation/test
[jtraining, jtest, jval] = splitTrainingTest(class, 50, 50, 1);
class_training = class(jtraining);
class_test = class(jtest);

descriptors = {'gist', 'sift', 'hog'};

for m = 1:length(descriptors)
    % svm parameters
    lambda = 0.2;
    opt.iter_max_Newton = 200;
    opt.cg = 1;
    
    % building kernel
    global K
    switch descriptors{m}
        case 'gist'
            svm.type = 'rbf';
            svm.sig = .6;
            
            % select gist
            Ftraining = gist(jtraining, :);
            Ftest = gist(jtest, :);

        case 'sift'
            
            % building kernel
            svm.type = 'histintersection';
            
            % select gist
            Ftraining = sptHistsift(jtraining, :);
            Ftest = sptHistsift(jtest, :);
            
        case 'hog'
            
            % building kernel
            svm.type = 'histintersection';
            
            % select gist
            Ftraining = sptHisthog(jtraining, :);
            Ftest = sptHisthog(jtest, :);
    end
    
    % train and test
    K = kernel(Ftraining, Ftraining, svm);
    Kt = kernel(Ftest, Ftraining, svm);
    
    [dg, n] = sort(K, 'descend');
    figure
    for i = 1:16
        img = LMimread(D(jtraining), n(i), HOMEIMAGES);
        subplot(4,4,i)
        imshow(img)
    end
    
    score_test = zeros(length(class_test), length(categories));
    figure
    for c = 1:length(categories)
        % train
        Y = 2*(class_training' == c)-1;
        [beta,b]=primal_svm(0, Y, lambda, opt);
        
        % test
        score_test(:,c) = Kt*beta+b;
        
        % evaluation single class
        subplot(3,3,c)
        areaROC(score_test(:,c), class_test'==c, 'r')
        title(categories{c})
        drawnow
    end
    
    % evaluation multi-class
    [s,class_hat] = max(score_test, [], 2);
    C = confusionMatrix(class_test, class_hat');
    subplot(121); title(descriptors{m})
    
    perf = mean(diag(C));
end



