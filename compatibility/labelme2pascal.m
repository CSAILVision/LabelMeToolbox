function labelme2pascal(D, databasename, HOMELMIMAGES, folderdestination)
%
% HOMELMIMAGES = 'http://labelme.csail.mit.edu/Images';
% pascalfolder = '/databases/'
% databasename = 'SUN';
%
% labelme2pascal(D, databasename, HOMELMIMAGES, pascalfolder)

% mark as 'difficult' objects that are smaller than this bounding box:
minH = 32;
minW = 32;
% Objects marked as difficult are not currently being considered in the
% pascal evaluation.

Nimages = length(D);

% Create folders
mkdir(fullfile(folderdestination, databasename, 'JPEGImages'))
mkdir(fullfile(folderdestination, databasename, 'Annotations'))
mkdir(fullfile(folderdestination, databasename, 'ImageSets', 'Main'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Split training/test by selecting equal number of images per folder
Ntraining = .5; % percentage images used for training
scenes = folder2class(D);
train = []; test = []; validation = [];
for i = 1:max(scenes)
    j = find(scenes==i);
    N = length(j);
    j = j(randperm(N));
    
    train = [train; j(1:fix(N*Ntraining+rand))];
    %test =  [test setdiff(j, train)];
end
test = setdiff(1:length(D), train);


% save test.txt file with image ids
fid=fopen(fullfile(folderdestination, databasename, 'ImageSets', 'Main', 'test.txt'), 'w');
for i = 1:length(test)
    fprintf(fid, '%s\n', strrep(D(test(i)).annotation.filename, '.jpg', ''));
end
fclose(fid)

% save train.txt file with image ids
fid=fopen(fullfile(folderdestination, databasename, 'ImageSets', 'Main', 'train.txt'), 'w');
for i = 1:length(train)
    fprintf(fid, '%s\n', strrep(D(train(i)).annotation.filename, '.jpg', ''));
end
fclose(fid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create summary report (a text file with number of instances.)
[objectnames, instancecounts] = LMobjectstats(D);
counts = full(sum(instancecounts,2));
counts_test = full(sum(instancecounts(:, test),2));
counts_train = full(sum(instancecounts(:, train),2));
[counts,jj] = sort(counts, 'descend');
names = objectnames(jj);
counts_test = counts_test(jj);
counts_train = counts_train(jj);

fid=fopen(fullfile(folderdestination, databasename, 'report.txt'), 'w');
fprintf(fid, '%4s  %22s %5s  %5s \n', 'ndx', 'Name', 'Train', 'Test')
for i = 1:length(objectnames)
    fprintf(fid, '%4d  %22s %5d  %5d \n', i, names{i}, counts_train(i), counts_test(i))
end
fclose(fid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD - AND WRITE IMAGES
disp('Writing images')
for n = 1:Nimages
    filename = D(n).annotation.filename;
    filename_annotation =  strrep(filename,'.jpg','.xml');
    
    % progresive download of images
    if exist(fullfile(folderdestination, databasename, 'JPEGImages', filename), 'file')
        disp(sprintf('%d/%d) %s ALREADY IN THE FOLDER', n, Nimages, filename))
        
        nrows = D(n).annotation.imagesize.nrows;
        ncols = D(n).annotation.imagesize.ncols;
        cc = 3;
    else
        disp(sprintf('%d/%d) %s', n, Nimages, filename))
        
        % Load image
        img = LMimread(D, n, HOMELMIMAGES); % Load image
        [nrows ncols cc] = size(img);
        
        % Write image
        imwrite(img, fullfile(folderdestination, databasename, 'JPEGImages', filename), 'jpg', 'quality', 100);
    end
    
    % the annotations are reconstructed from D even if the image is already
    % downloaded.
    Nobjects = LMcountobject(D(n));
    
    % Translate annotation to pascal format
    clear v
    v.annotation.folder = databasename;
    v.annotation.filename = filename;
    v.annotation.source.database = databasename;
    v.annotation.source.image = '';
    v.annotation.size.width = ncols;
    v.annotation.size.height = nrows;
    v.annotation.size.depth = cc;
    v.annotation.segmented = 0;
    
    if Nobjects>0
        boundingbox = LMobjectboundingbox(D(n).annotation); % [xmin ymin xmax ymax]
        for m = 1:Nobjects
            v.annotation.object(m).name = D(n).annotation.object(m).name;
            if isfield(D(n).annotation.object(m), 'attributes')
                v.annotation.object(m).attributes = D(n).annotation.object(m).attributes;
            end
            v.annotation.object(m).bndbox.xmin = boundingbox(m,1);
            v.annotation.object(m).bndbox.ymin = boundingbox(m,2);
            v.annotation.object(m).bndbox.xmax = boundingbox(m,3);
            v.annotation.object(m).bndbox.ymax = boundingbox(m,4);
            v.annotation.object(m).polygon = D(n).annotation.object(m).polygon; % this keeps the segmentation information from labelme
            if ~isfield(D(n).annotation.object(m), 'crop')
                D(n).annotation.object(m).crop = '0';
            end
            
            if isnumeric(D(n).annotation.object(m).crop)
                D(n).annotation.object(m).crop = num2str(D(n).annotation.object(m).crop);
            end
            
            v.annotation.object(m).truncated = D(n).annotation.object(m).crop;
            v.annotation.object(m).crop = D(n).annotation.object(m).crop;
            if strcmp(strtrim(D(n).annotation.object(m).crop), '1') || boundingbox(m,4)-boundingbox(m,2)<minH || boundingbox(m,3)-boundingbox(m,1)<minW
                v.annotation.object(m).difficult = '1';
            else
                v.annotation.object(m).difficult = '0';
            end
        end
    end
    
    % Write annotation file
    writeXML(fullfile(folderdestination, databasename, 'Annotations', filename_annotation), v);
end


