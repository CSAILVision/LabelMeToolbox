function ADMINcopyfolderstructure(ORIGINALFOLDER, MIRRORFOLDER)
%
% ADMINcopyfolderstructure(ORIGINALFOLDER, MIRRORFOLDER)
%
% ORIGINALFOLDER
% MIRRORFOLDER  -> here goes the new folders


% create list of folders
folders = genpath(ORIGINALFOLDER);
h = [findstr(folders,  pathsep)];
h = [0 h];
Nfolders = length(h)-1
for i = 1:Nfolders
    tmp = folders(h(i)+1:h(i+1)-1);
    tmp = strrep(tmp, ORIGINALFOLDER, ''); tmp = tmp(2:end);
    Folder{i} = tmp;
end


% make new folders
for f = 1:Nfolders
    folder = fullfile(MIRRORFOLDER, Folder{f});

    if ~exist(folder, 'dir')
        mkdir(folder);
    else
        disp('folders already exist in target folder')
    end
end
