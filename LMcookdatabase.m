function LMcookdatabase(database, HOMEIMAGES, HOMEANNOTATIONS, NEWHOMEIMAGES, NEWHOMEANNOTATIONS, varargin)
% You can "cook" your own database by reformating the images and the
% annotation files so that the images in the database have some
% characteristics of interest. For instance, you might want a database in
% which all the images are smaller that 256 x 256. Or you might want a
% database of images that have cars, so that each car has a size of 32x32 pixels.
%
% This function captures some of the most common charcteristics for
% standarizing the databases. 
%
% List of parameters
%   -----------------------
%   'imagesize'       [nrows ncols] 
%
%   'objectname'      defines which will be the object of interest
%
%   'objectsize'      A number between 1 and inf; It is the size of the
%                     object of interest in the final image.
%
%   'objectlocation'  Defines the location of the object in the new image. 
%                     One of these strings: 'original', 'random', 'centered'
%
%   'multiplecrops'   One of these strings: 'yes', 'no'. 
%                     If there are multiple instances of the object of
%                     interest, it will create one image for each instance.
%
% Example:
% The next code generates a new database with street scenes. In the final
% database, there are only images with one car in each image. The images
% will have a maximal size of 256x256 pixels, and the car will have a fixed
% size of 64x64 (tight to the longest dimension).
%
%   %Define the root folder for the images
%   HOMEIMAGES = 'C:\atb\Databases\CSAILobjectsAndScenes\Images'; % you can set here your default folder
%   HOMEANNOTATIONS = 'C:\atb\DATABASES\LabelMe\Annotations'; % you can set here your default folder
%
%   %Define the root folder for the images
%   NEWHOMEIMAGES = 'C:\atb\Projects\objectsAndScenes\generativeModels\iccv2005\database\streets\Images'; % you can set here your default folder
%   NEWHOMEANNOTATIONS = 'C:\atb\Projects\objectsAndScenes\generativeModels\iccv2005\database\streets\Annotations'; % you can set here your default folder
%
%   %Create database
%   database = LMdatabase(HOMEANNOTATIONS);
%
%   %Locate street scenes with only one car. 
%   [D,j]  = LMquery(database, 'object.name', 'car+side');
%   counts = LMcountobject(database(j), 'car');
%   j = j(find(counts==1)); length(j)
%   D  = LMquery(database(j), 'object.name', 'car+side,building,road');
%   LMdbshowscenes(D, HOMEIMAGES);
%
%   %Cook database to fit our requirements: objects of fixed size
%   LMcookdatabase(D, HOMEIMAGES, HOMEANNOTATIONS, NEWHOMEIMAGES, NEWHOMEANNOTATIONS, ...
%    'objectname', 'car', 'objectsize', [64 64], 'objectlocation', 'original', 'maximagesize', [256 256])


variables = {'maximagesize', 'objectname', 'objectsize', 'objectlocation', 'multiplecrops', 'impad', 'minobjectsize', 'polygoninstance'};
defaults = {[], '', [], 'original', 'no', [], [], []};
[maximagesize, objectname, objectsize, objectlocation, multiplecrops, impad, minobjectsize, polygoninstance] = ...
    parseparameters(varargin, variables, defaults);

% Create structure of files:
Nfiles = length(database);
for i = 1:Nfiles
    folders{i} = database(i).annotation.folder;
end
folders = unique(folders);
Nfolders = length(folders);

if length(dir(NEWHOMEIMAGES))>0; error(sprintf('Error: The folder %s already exists.', NEWHOMEIMAGES)); end
if length(dir(NEWHOMEANNOTATIONS))>0; error(sprintf('Error: The folder %s already exists.', NEWHOMEANNOTATIONS)); end

for i = 1:Nfolders
    mkdir(NEWHOMEIMAGES, folders{i});
    mkdir(NEWHOMEANNOTATIONS, folders{i});
end

% Save readme file in the root of the NEWHOMEANNOTATIONS and NEWHOMEIMAGES
readme{1} = 'This database is a subset of the LabelMe dataset.';
readme{2} = 'http://people.csail.mit.edu/brussell/research/LabelMe/intro.html';
readme{3} = '';
readme{4} = 'This dataset has been created with the parameters:';
for n=1:length(varargin); readme{4+n} = varargin{n}; end

fid = fopen(fullfile(NEWHOMEIMAGES, 'readme.txt'), 'w');
for i = 1:length(readme)
    fprintf(fid, '%s \n', readme{i});
end
fclose(fid)


% Create new database
for n = 1:Nfiles
    clear newannotation newimg err
    img = LMimread(database, n, HOMEIMAGES); % Load image

    if strcmp(multiplecrops, 'yes')
        % we will do the image manipulation by centering on each instance. 
        Nimages = length(database(n).annotation.object);
        
        for m = 1:Nimages
            [newannotation{m}, newimg{m}, crop, scaling, err{m}, msg] = LMcookimage(database(n).annotation, img, varargin{:}, 'polygoninstance', m);
        end
    else
        Nimages = 1;
        [newannotation{1}, newimg{1}, crop, scaling, err{1}, msg] = LMcookimage(database(n).annotation, img, varargin{:});
    end

    % The images are saved only if there was no upsampling (no blur)
    for m = 1:Nimages
        if err{m} == 0
            % Save image and annotation
            if Nimages==1
                filename = database(n).annotation.filename;
            else
                filename = sprintf('%s_crop%d.jpg', strrep(database(n).annotation.filename, '.jpg', ''), m);
            end

            % write new image
            imwrite(newimg{m}, fullfile(NEWHOMEIMAGES, database(n).annotation.folder, filename), 'jpg', 'quality', 100);

            % write new annotation file
            v.annotation = newannotation{m};
            v.annotation.filename = filename;
            writeXML(fullfile(NEWHOMEANNOTATIONS, database(n).annotation.folder, strrep(filename,'.jpg','.xml')), v);

            figure(1); clf
            subplottight(1,2,1)
            LMplot(database(n).annotation, img)
            subplottight(1,2,2)
            LMplot(newannotation{m}, newimg{m})
            title(sprintf('%d/%d', n, Nfiles))
            xlabel(strrep(fullfile(database(n).annotation.folder, filename), '\', '/'))
            drawnow
        end
    end
end



