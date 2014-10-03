% Releases

% SUN'2012
%    - 397 scene categories full image set
%    - 17000 annotated images

% SUN'2009
%    - 12000 annotated images
%
% 397-SUN

%addpath('/Users/torralba/atb/MatlabTools/LabelMeToolbox')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Building dataset of annotated images
HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations';
HOMEIMAGES = 'http://labelme.csail.mit.edu/Images';
baseFolderDestination = '/csail/vision-torralba/datasets/';


% Build SUN index
disp('Reading folder list')
folder = folderlist(HOMEANNOTATIONS, 'users/antonio/static_sun_database');

disp('create index')
D = LMdatabase(HOMEANNOTATIONS, folder);


% Remove MT images
disp('remove Mechanical turk')
D = LMquery(D, 'object.polygon.username', '-mt_');


% Remove duplicate images
% get list of duplicate images
disp('remove duplicate files')
load dupFiles
dup = []; i = 0;
for n = 1:size(Sfiles,1)
    for m = 1:6
        f = Sfiles{n,m};
        if ~isempty(f)
            i = i + 1;
            k=max(strfind(f, '/'));
            f = f(k+1:end);
            dup{i} = f;
        end
    end
end
j_dup = [];
for n = 1:length(D)
    k = strmatch(D(n).annotation.filename, dup);
    if ~isempty(k)
        j_dup = [j_dup n];
    end
end

D = D(setdiff(1:length(D), j_dup));    

% Remove empty images
%counts = LMcountobject(D);
%D = D(counts>0);

% Remove unreadable images
%readable = zeros(length(D),1);
%for i = 1:length(D)
%    disp(i)
%    try
%        img = LMimread(D, i, HOMEIMAGES);
%        D(i).annotation.imagesize.nrows = size(img,1);
%        D(i).annotation.imagesize.ncols = size(img,2);
%        readable(i) = 1;
%    catch
%        readable(i) = 0;
%    end
%    disp(sum(1-readable(1:i)))
%end

% Remove partially labeled images
disp('remove partially labeled images')
relativearea = LMlabeledarea(D);
good = find(relativearea>.8);
D = D(good);

% Add cropped tag
D = addcroplabel(D);

% Tags
%D = LMaddtags(D, 'tagsSUN.txt');


% Create list of images and paths
clear images folders
for i = 1:length(D)
    images{i} = D(i).annotation.filename;
    tmp = D(i).annotation.folder;
    tmp = strrep(tmp, 'users/antonio/static_sun_database/', '');
    folders{i} = tmp;
end

%destImages = '/Users/torralba/atb/Databases/SUN2012/Images';
%destAnnotations = '/Users/torralba/atb/Databases/SUN2012/Annotations/';
disp('Install SUN')
destImages = fullfile(baseFolderDestination, 'SUN2012/Images/');
destAnnotations = fullfile(baseFolderDestination, 'SUN2012/Annotations/');
LMinstall(folders, images, destImages, destAnnotations, 'http://labelme.csail.mit.edu/Images/users/antonio/static_sun_database/', 'http://labelme.csail.mit.edu/Annotations/users/antonio/static_sun_database/');



% make sure folder names are coherent
ADMINrenamefolder(destAnnotations);

Dtest = LMdatabase(destAnnotations, destImages);

% Make labelMe format:
% pascalfolder = '/Users/torralba/atb/Databases';
disp('create PASCAL release')
pascalfolder = baseFolderDestination;
databasename = 'SUN2012pascalformat';

labelme2pascal(Dtest, databasename, destImages, pascalfolder)


