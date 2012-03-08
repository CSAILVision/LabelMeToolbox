function ADMINrenamefolder(HOMEANNOTATIONS, Folder)
%
% Writes in the folder field of the xml file the nane of the folder in
% which the annotation files are.
%
% This script is useful when moving annotation files into other folders
% manually. This function guaratees consistency.


% Create list of folders
if nargin == 1
    folders = genpath(HOMEANNOTATIONS);
    h = [findstr(folders,  pathsep)];
    h = [0 h];
    Nfolders = length(h)-1;
    for i = 1:Nfolders
        tmp = folders(h(i)+1:h(i+1)-1);
        tmp = strrep(tmp, HOMEANNOTATIONS, ''); tmp = tmp(2:end);
        Folder{i} = tmp;
    end
end

Nfolders = length(Folder);

for m = 1:Nfolders
    annotationfolder = strrep(Folder{m}, '\', '/');
    files = dir(fullfile(HOMEANNOTATIONS, annotationfolder, '*.xml'));

    Nfiles = length(files);
    for i = 1:Nfiles
        v = loadXML(fullfile(HOMEANNOTATIONS, annotationfolder, files(i).name));
        if isfield(v.annotation, 'folder')
            if ~strcmp(v.annotation.folder,annotationfolder)
                v.annotation.folder = annotationfolder;
                writeXML(fullfile(HOMEANNOTATIONS, annotationfolder, files(i).name), v);
                
                disp(sprintf('%d, %d) %s, changed', m,i,files(i).name))
            else
                disp(sprintf('%d, %d) %s, already goo', m,i,files(i).name))
            end
        else
            disp(sprintf('%d, %d) %s, no folder field', m,i,files(i).name))
        end
    end
end

