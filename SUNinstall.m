function SUNinstall(destImages, destAnnotations, folder)
%
% SUNinstall(destImages, destAnnotations)
%
% To download a single folder add a third argument:
% SUNinstall(destImages, destAnnotations, folder)

HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations/users/antonio/static_sun_database';
HOMEIMAGES = 'http://labelme.csail.mit.edu/Images/users/antonio/static_sun_database';

% Build SUN index
disp('Reading folder list')
if nargin == 3
    folder = folderlist(HOMEANNOTATIONS, folder);
else
    folder = folderlist(HOMEANNOTATIONS);
end

% create list of folders to copy, copy and rename folders in XML:
LMinstall(folder, destImages, destAnnotations, HOMEIMAGES, HOMEANNOTATIONS)

% make sure folder names are coherent
ADMINrenamefolder(destAnnotations);



