function [D, folder, HOMEIMAGES, HOMEANNOTATIONS] = SUNdatabase(folder)
%
% Creates the index of the SUN database reading the online folders
%
% Probably you are looking for SUNinstall which will allow you to download
% the latest copy of the SUN database

HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations';
HOMEIMAGES = 'http://labelme.csail.mit.edu/Images';

% Build SUN index
disp('Reading folder list')
if nargin == 1
    folder = folderlist(HOMEANNOTATIONS, fullfile('users/antonio/static_sun_database', folder));
else
    load SUNfolderlist
    %disp('Downloading the database will take some time... be patient.')
    %folder = folderlist(HOMEANNOTATIONS, 'users/antonio/static_sun_database');
end

disp('create index')
D = LMdatabase(HOMEANNOTATIONS, folder);

% Remove AMT images
%D = LMquery(D, 'object.polygon.username', '-mt_');


% Remove duplicate images
% get list of duplicate images
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



