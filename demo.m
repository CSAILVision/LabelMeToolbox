%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LabelMe
%
% This script contains a number of examples about how to use the most
% important functions of this toolbox.
%
% You need to download all the images and annotations first.
% http://people.csail.mit.edu/brussell/research/LabelMe/intro.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This introducion has four parts: 
% 1) functions for the manipulation of individual files
% 2) functions for building a database and searching for objects and images
% 3) functions for reformating the database for test and training
% 4) functions for connecting with the online annotation tool

clear all

% Define the root folder for the images
HOMEIMAGES = 'C:\atb\Databases\sceneCategories\Images'; % you can set here your default folder
HOMEANNOTATIONS = 'C:\atb\Databases\sceneCategories\Annotations'; % you can set here your default folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 1) MANIPULATION OF INDIVIDUAL FILES:

% select one annotation file from one of the folders:
filename = fullfile(HOMEANNOTATIONS, 'spatial_envelope_256x256_static_8outdoorcategories', 'insidecity_bost42.xml');
% read the image and annotation struct:
[annotation, img] = LMread(filename, HOMEIMAGES);
% plot the annotations
LMplot(annotation, img)

% you can manipulate the image and the corresponding annotation with the
% functions: LMimscale, LMimcrop, LMimpad and LMcookimage. LMcookimage is a
% generic function that can perform many different operations.

[newannotation, newimg, crop, scaling, err, msg] = LMcookimage(annotation, img, 'maximagesize', [256 256], 'impad', 255);
LMplot(newannotation, newimg)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 2) INDEXING AND VISUALIZING THE DATABASE:

% This line reads the entire database into a Matlab struct
database = LMdatabase(HOMEANNOTATIONS);

% QUERIES:
% The function LMquery searchs for images in the database.
% Queries can be done on any field of the struct array.
% The fields for an image are:
%    filename
%    folder
%    source.sourceImage
%    source.sourceAnnotation
%    object(:).name
%    object(:).deleted
%    object(:).verified
%    object(:).date
%    object(:).polygon.username
%    object(:).polygon.pt(:).x
%    object(:).polygon.pt(:).y
%    object(:).viewpoint.azimuth


% Queries for objects
[D,j] = LMquery(database, 'object.name', 'building');
LMdbshowscenes(database(j), HOMEIMAGES); % this shows all the objects in the images that contain buildings
LMdbshowscenes(D, HOMEIMAGES); % this shows only the buildings

% Queries for images in specific folders. 
[D,j] = LMquery(database, 'folder', '05june05_static_indoor');
LMdbshowscenes(database(j), HOMEIMAGES); % this shows all the objects

% The next example shows the annotated objects from images that come from the web:
[D,j] = LMquery(database, 'folder', 'web');
LMdbshowscenes(database(j), HOMEIMAGES); % this shows all the objects

% look for a specific image file:
[D,j] = LMquery(database, 'filename', 'p1010843.jpg');
LMdbshowscenes(database(j), HOMEIMAGES); % this shows all the objects

% look for objects annotated by one user:
[D,j] = LMquery(database, 'object.polygon.username', 'atb');
LMdbshowscenes(D, HOMEIMAGES); % this shows all the objects annotated by one user

% look for objects by viewpoint:
[D,j] = LMquery(database, 'object.viewpoint.azimuth', '0', 'exact');

% Other examples
LMdbshowscenes(LMquery(database, 'object.name', 'car'), HOMEIMAGES);
LMdbshowscenes(LMquery(database, 'object.date', '08-Jul-2005'), HOMEIMAGES);
LMdbshowscenes(LMquery(database, 'object.name', 'personWalking'), HOMEIMAGES);
LMdbshowscenes(LMquery(database, 'object.deleted', '1'), HOMEIMAGES); % shows all the images that have at least one deleted polygon

% Composing queries:
% you can query for polygon names that contain multiple strings. 
[D,j] = LMquery(database, 'object.name', 'car+side');
LMdbshowscenes(D, HOMEIMAGES); % this shows only the car side views
LMdbshowobjects(D, HOMEIMAGES); % this show tight crops of car side views.

LMdbshowscenes(LMquery(database, 'object.name', 'car+window'), HOMEIMAGES);
LMdbshowscenes(LMquery(database, 'object.name', 'car+frontal'), HOMEIMAGES);

% exclusion can be used to narrow down a search. Compare this two:
LMdbshowobjects(LMquery(database, 'object.name', 'mouse+pad'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'mouse-pad'), HOMEIMAGES);
% note that the next query provides a mixture of the two, which might not
% be the desired outcome:
LMdbshowobjects(LMquery(database, 'object.name', 'mouse'), HOMEIMAGES);



% This shows polygons that belong to only one of the next four object classes.
LMdbshowscenes(LMquery(database, 'object.name', 'car+side,building,road,tree'), HOMEIMAGES);

% Street scenes
% To get images that have trees, buildings and roads:
[D,j1] = LMquery(database, 'object.name', 'building');
[D,j2] = LMquery(database, 'object.name', 'road');
[D,j3] = LMquery(database, 'object.name', 'tree');
j = intersect(intersect(j1,j2),j3);
LMdbshowscenes(LMquery(database(j), 'object.name', 'car,building,road,tree'), HOMEIMAGES);

% Office scenes
% To get images that have screens, desks and keyboards:
[D,j1] = LMquery(database, 'object.name', 'screen+frontal');
[D,j2] = LMquery(database, 'object.name', 'desk');
[D,j3] = LMquery(database, 'object.name', 'keyboard');
j = intersect(intersect(j1,j2),j3);
LMdbshowscenes(LMquery(database(j), 'object.name', 'mousepad,keyboard,screen,desk'), HOMEIMAGES);


% Pedestrian scenes
[D,j] = LMquery(database, 'object.name', 'pedestrian+walking');
LMdbshowscenes(D);
LMdbshowobjects(D, HOMEIMAGES)

% You can see the list of words associated with an object class using the
% command LMobjectnames:
LMobjectnames(LMquery(database, 'object.name', 'face'))
LMobjectnames(LMquery(database, 'object.name', 'plate'))
LMobjectnames(LMquery(database, 'object.name', 'person'))


% VISUALIZATIONS:
% You can visualize the individual objects or their segmentations within
% the large scenes. Compare the next two functions:
LMdbshowobjects(LMquery(database, 'object.name', 'wheel'), HOMEIMAGES);
LMdbshowscenes(LMquery(database, 'object.name', 'wheel'), HOMEIMAGES);

% SEVERAL OBJECT CROPS:
LMdbshowobjects(LMquery(database, 'object.name', 'face', 'exact'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'wheel'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'firehydrant'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'plate+license'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'plate-license'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'one+way+sign'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'stop+sign'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'mug'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'can'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'paper+cup'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'fork'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'exit+sign'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'car+side'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'car+frontal'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'cone'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'trash+whole'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'traffic+light'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'sofa'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'chair+whole'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'bicycle+side'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'bookshelf+frontal'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'screen+frontal'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'knob'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'lamp+table'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'hand-le'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'laptop'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'bottle'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'person+walking'), HOMEIMAGES);
LMdbshowobjects(LMquery(database, 'object.name', 'orange'), HOMEIMAGES);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 3) CREATING SPECIALIZED DATABASES: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% you can "cook" your own database by reformating the images and the
% annotation files so that the images in the database have some
% characteristics of interest. For instance, you might want a database in
% which all the images are smaller that 256 x 256. Or you might want a
% database of images that have cars, so that each car has a size of 32x32 pixels.


clear all

% Define the root folder for the images
HOMEIMAGES = 'C:\atb\Databases\CSAILobjectsAndScenes\Images'; % you can set here your default folder
HOMEANNOTATIONS = 'C:\atb\DATABASES\LabelMe\Annotations'; % you can set here your default folder

% Define the root folder for the images
NEWHOMEIMAGES = 'C:\atb\Projects\objectsAndScenes\generativeModels\iccv2005\database\streets\Images'; % you can set here your default folder
NEWHOMEANNOTATIONS = 'C:\atb\Projects\objectsAndScenes\generativeModels\iccv2005\database\streets\Annotations'; % you can set here your default folder

% Create database
database = LMdatabase(HOMEANNOTATIONS);

% Locate street scenes with only one car. 
[D,j]  = LMquery(database, 'object.name', 'car+side');length(j)
counts = LMcountobject(database(j), 'car');
j = j(find(counts==1)); length(j)
D  = LMquery(database(j), 'object.name', 'car+side,building,road');
% LMdbshowscenes(D, HOMEIMAGES);

% Cook database to fit our requirements: objects of fixed size
LMcookdatabase(D, HOMEIMAGES, HOMEANNOTATIONS, NEWHOMEIMAGES, NEWHOMEANNOTATIONS, ...
    'objectname', 'car', 'objectsize', [64 64], 'objectlocation', 'original','maximagesize', [256 256])

% Load new database
newdatabase = LMdatabase(NEWHOMEANNOTATIONS);

LMdbshowscenes(newdatabase, NEWHOMEIMAGES);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

% Define the root folder for the images
HOMEIMAGES = 'C:\atb\Databases\CSAILobjectsAndScenes\Images'; % you can set here your default folder
HOMEANNOTATIONS = 'C:\atb\DATABASES\LabelMe\Annotations'; % you can set here your default folder

% Define the root folder for the images
NEWHOMEIMAGES = 'C:\atb\Projects\objectsAndScenes\generativeModels\iccv2005\database\office\Images'; % you can set here your default folder
NEWHOMEANNOTATIONS = 'C:\atb\Projects\objectsAndScenes\generativeModels\iccv2005\database\office\Annotations'; % you can set here your default folder

database = LMdatabase(HOMEANNOTATIONS);

% Locate office scenes with only one screen. 
[D,j]  = LMquery(database, 'object.name', 'screen+frontal');length(j)
counts = LMcountobject(database(j), 'screen');
j = j(find(counts==1)); length(j)
D  = LMquery(database(j), 'object.name', 'screen,keyboard,mouse-pad');
% LMdbshowscenes(D, HOMEIMAGES);

% Cook database to fit our requirements: objects of fixed size
LMcookdatabase(D, HOMEIMAGES, HOMEANNOTATIONS, NEWHOMEIMAGES, NEWHOMEANNOTATIONS, ...
    'objectname', 'screen', 'objectsize', [64 64], 'objectlocation', 'original','maximagesize', [128 128])

% Load new database
newdatabase = LMdatabase(NEWHOMEANNOTATIONS);

LMdbshowscenes(newdatabase, NEWHOMEIMAGES);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example that creates a database with tightly cropped objects:

% Define the root folder for the images
HOMEIMAGES = 'C:\atb\Databases\CSAILobjectsAndScenes\Images'; % you can set here your default folder
HOMEANNOTATIONS = 'C:\atb\DATABASES\LabelMe\Annotations'; % you can set here your default folder

% Define the root folder for the images
NEWHOMEIMAGES = 'C:\atb\Projects\objectsAndScenes\generativeModels\objectsLDA\LDApatches\databaseObjects\imagesSharing\Images'; % you can set here your default folder
NEWHOMEANNOTATIONS = 'C:\atb\Projects\objectsAndScenes\generativeModels\objectsLDA\LDApatches\databaseObjects\imagesSharing\Annotations'; % you can set here your default folder

database = LMdatabase(HOMEANNOTATIONS);

% Locate office scenes with only one screen. 
[D,j]  = LMquery(database, 'object.name', 'car+side');length(j)

% Cook database to fit our requirements: objects of fixed size
LMcookdatabase(D, HOMEIMAGES, HOMEANNOTATIONS, NEWHOMEIMAGES, NEWHOMEANNOTATIONS, ...
    'objectname', 'car+side', 'objectsize', [126 126], 'objectlocation', 'centered','maximagesize', [128 128])

% Load new database
newdatabase = LMdatabase(NEWHOMEANNOTATIONS);
LMdbshowscenes(newdatabase, NEWHOMEIMAGES);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PART 4) WEB TOOLS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The goal of this set of tools is to allow you to create applications that
% can use the tool online. Here we show you the functions we propose and
% how can you build applications. But here you can also contribute new
% functions and ways of making use of the online tool. The goal is not to
% hack the database, but to make something useful for you and the rest of
% the people using the database.

% Create a photoalbum that allows annotating specific images. You can use
% the query tool to preselect a set of images. For instance, here we are
% interested in labeling the objects of the Kitchen scenes. Therefore,
% first we query the images using the 'folder' field (which generally
% contains information about the scene category), then we create a list of
% images and folders, and finally we call the LMphotoalbum tool.
[D,j] = LMquery(database, 'folder', 'kitchen');
clear folderlist filelist
for i = 1:length(D);
    folderlist{i} = D(i).annotation.folder;
    filelist{i} = D(i).annotation.filename;
end
LMphotoalbum(folderlist, filelist, 'myphotoalbum.html', HOMEIMAGES);
% The output is a web page called 'myphotoalbum.html'. Open that page to
% see the content.
%
% If your browser can visualize frames, then the next command can be more
% interesting:

LMthumbnailsbar(folderlist, filelist, 'myphotoalbum.html', HOMEIMAGES);

% The Photoalbum allows you adding more labels to specific images. After you have done that, you can use LMupdate to 
% load the new annotations into your local copy without needing to load the entire database. 
LMupdate(folderlist, filelist, HOMEIMAGES, HOMEANNOTATIONS);
% This function will access the annotation files online, and will replace
% your local files, only for the images specified in the list. 

% You do not need to download the database. The functions that read the
% images and the annotation files can be refered to the online tool. For
% instance, you can run the next command:
HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations'
database = LMdatabase(HOMEANNOTATIONS);
% This will create the database struct without needing to download the
% database. It might be slower than having a local copy. You can do the
% same for the images:

HOMEIMAGES = 'http://labelme.csail.mit.edu/Images'

% You can now use the functions such as LMcookdatabase to create a local
% copy of the database with only the images that interest you without needing 
% to download the entire database. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Install a selected folder from the LabelMe.
% For instance, if we want to download only two folders (annotations and
% images):
HOMEIMAGES = 'C:\labelme\Images'
HOMEANNOTATIONS = 'C:\labelme\Annotations'

folderlist = {'05june05_static_street_boston', '05june05_static_street_porter'};
LMinstall(folderlist, HOMEIMAGES, HOMEANNOTATIONS);




