function APPdownload(username, destImages, destAnnotations)
% Downloads the images and annotations collected with the LabelMe app.
%
% For more details visit:
% http://labelme2.csail.mit.edu/Release3.0/browserTools/php/iPhoneHelp.php
%
% Usage:
%
%   APPdownload(username)
%
%   or, you can specify the destination folders where the images and
%   annotations will be saved:
%
%   APPdownload(username, destImages, destAnnotations)
%
% Example:
%   APPdownload(username)
%   D=LMdatabase('Annotations');
%   LMdbshowscenes(D, 'Images');


if nargin == 1
    destImages = 'Images';
    destAnnotations = 'Annotations';
end

HOMEANNOTATIONS = ['http://labelme.csail.mit.edu/Annotations/users/' username];
HOMEIMAGES = ['http://labelme.csail.mit.edu/Images/users/' username];

% folder index
folder = {'iPhoneCollection'};

% create list of folders to copy, copy and rename folders in XML:
LMinstall(folder, destImages, destAnnotations, HOMEIMAGES, HOMEANNOTATIONS)

% make sure folder names are coherent
ADMINrenamefolder(destAnnotations);



