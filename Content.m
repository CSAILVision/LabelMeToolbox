%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB Toolbox for LabelMe Image Database
% Release January 1, 2007
%
% If you use this toolbox, we only ask you to contribute to the database, 
% from time to time, by using the labeling tool.
%
% We will appreciate if you cite our paper:
%
% LabelMe: a database and web-based tool for image annotation
%    B. Russell, A. Torralba, K. Murphy, W. T. Freeman
%    International Journal of Computer Vision, pages 157-173, Volume 77,
%    Numbers 1-3, May, 2008.
%
% LabelMe is a WEB-based image annotation tool: 
% http://people.csail.mit.edu/brussell/research/LabelMe/intro.html
% This tool allows researchers to label images and share the annotations with
% the rest of the community.
%
% (c) Antonio Torralba, Bryan Russell, William T. Freeman, 2005.
% -------------------------------------------------------------------------
%
% Introduction
%   demo                - contains examples of how to use several functions
%
% LabelMe tools for reading and ploting the annotations of individual files
%   LMread              - reads one image and the corresponding annotation XML file
%   LMplot              - image and polygons visualization
%
% LabelMe Database tools
%   LMdatabase          - loads all the annotations into a big database struct
%   LMdbshowscenes      - shows thumbnails for the all the images in the database. Combined with query can show images with only certain objects.
%   LMdbshowobjects     - shows crops of the objects in the database.
%   LMobjectnames       - returns a list with the name of all the objects in the database
%   LMobjectindex       - retuns the indices of an object class within the annotation struct
%   LMvalidobjects      
%
% Search tools
%   LMquery             - performs a query on the database using any field
%   LMquerypolygon      - search for objects using shape matching
%   qLabelme            - search using the online search tool (it does not use the local index)
%
% Object stats
%   LMstats             - general LabelMe stats
%   LMobjectstats 
%   LMcountobject       - counts the number of instances of an object class in every image
%   objectareas
%   aspectratio
%
% Synonyms
%   LMreplaceobjectname - replaces object names
%
% WORDNET
%   demoWordnet         - examples 
%   LMaddwordnet        - adds to the object names, synonyms from wordnet.
%   showTree            - shows the hierarchycal wordnet tree.
%   wordnetGUI
%   removestopwords     - removes common words from object description
%   getWordnetSense     - returns Wordnet sense
%   findsenses          - suggest possible different meanings of a query.
%
% Object parts
%   suggestparts        - propose part candidates for an object
%   addparts
%   LMshowobjectparts
%
% Depth and 3D tools
%   LMsortlayers        - returns relative depth ordering between overlaping polygons
%
% Image manipulation
%   LMimscale           - scales the image and the corresponding annotation
%   LMimcrop            - crops the image and the corresponding annotation
%   LMimpad             - pads an image with PADVAL and modifies the annotation
%
% Objects, polygons and segmentation
%   LMobjectpolygon     - returns all the polygons for an object class within an image
%   LMobjectmask        - returns the segmentation mask for all object instances of one class within an image
%   LMobjectboundingbox - returns bounding boxes
%   LMobjectsinsideimage- removes polygons outside the image boundary
%   LMobjectcrop        - crops one selected object
%   LMobjectnormalizedcrop - crops one image into a normalized frame (as we
%                            need for training detectors)
%   LM2segments         - Transforms all the labelme labels into segmentation masks.
%   LM2objectsegments   - Extracts all the objects
%
%
% Creation of training and test images and databases
%   LMcookimage         - reformat an image and annotation to fit certain requirements.
%   LMcookdatabase      - create tuned databases (you can control the difficulty, the object size, ...)
%
% Communication with online annotation tool
%   LMphotoalbum        - creates a web page with thumbnails and connected to LabelMe online
%   LMthumbnailsbar     - creates a bar of thumbnails connected to LabelMe online
%
% Install and update images and annotations
%   LMinstall           - installs the database
%   LMupdate            - authomatic update of the annotations for specific files
%   LMprogressiveinstall- will update the local images with only the new images,
%                         and also download all of the annotations
% 
% Translation from/to other formats
%   PAS2LM              - Translates PASCAL format to LabelMe 
%   LM2OpenCV           - will output a query in format usable for OpenCV Haar 
%   caltech2LM          - Translates the 101 Caltech dataset (with polygons) into LabelMe format
%
% Object detection
%   LMrecallPrecision   - Precision-recall curve 
%
% XML tools (translates the XML files into MATLAB struct arrays):
%   writeXML            - translates a struct array into a XML file. 
%   loadXML             - read XML file
%   drawXML             - shows the image and plots the polygons 
%   xml2struct          - translates a XML string into a matlab struct
%   struct2xml          - translates a matlab struct into a XML string 
%
% Web tools
%   urldir              - like 'dir' but takes as argument a web address
%   LMgetfolderlist     - will return the list of folders from the online database
%
% Thumbnails: these two functions generate the thumbnails for scenes and
% objects shown in the LabelMe webpage
%   LMsceneThumbnail
%   LMobjectThumbnail
%
% Utility functions
%   parseparameters
%   colorSegments
%   subplottight        - like 'subplot' but removes spacing between axes
%   parseContent
%   findobject
%   countpolygons
%   getLMpolygon
%   addsmallobjectlabel - useful to remove small objects from the annotations
%   arrangefigs         - organizes all the open figures in the screen
%   segment2polygon     
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECT RECOGNITION AND SCENE UNDERSTANDING functions
%
% Gist
%   demoGist - demo script
%   LMgist - computes the gist for a set of images
%   showGist - visualization gist features for a set of images
%
% Dense SIFT
%   demoSIFT  - demo script
%   LMdenseSIFT - computes SIFT descriptors for a set of images on a dense grid
%   showColorSIFT - visualization of dense SIFT descriptors using a color code
%
% Dense HOG
%   demoHOG2x2  - demo script
%
% Visual words (SIFT & HOG)
%   demoVisualWords
%   LMkmeansVisualWords
%   LMdenseVisualWords  
%
% Utility functions
%   segment2polygon - takes a segments and extracts a polygon
%   folder2class    - the class is an index to the folder name
%   precisionRecall - computes precision-recall curves
%
% Ground truth for image similarity
%   LMobjhistintersection - uses the object labels to measure image similarity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To see more examples of how to use some of these functions, visit the FAQ
% page:
%
% http://labelme.csail.mit.edu/faq.html
%




