function ADMINrenamefolder(HOMEANNOTATIONS, Folder, replacebythis)
%
% Writes in the folder field of the xml file the nane of the folder in
% which the annotation files are.
%
% This script is useful when moving annotation files into other folders
% manually. This function guaratees consistency.
%
% You can also write in the folder field a pre-especified folder name:
% 
%  ADMINrenamefolder(HOMEANNOTATIONS, Folder, replacebythis)

% Create list of folders
if nargin == 1
    Folder = folderlist(HOMEANNOTATIONS);
end

Nfolders = length(Folder);

if isempty(Folder)
    Folder = {''};
end

for m = 1:Nfolders
    annotationfolder = strrep(Folder{m}, '\', '/');
    disp(annotationfolder)
    files = dir(fullfile(HOMEANNOTATIONS, annotationfolder, '*.xml'));

    Nfiles = length(files);
    for i = 1:Nfiles
        v = loadXML(fullfile(HOMEANNOTATIONS, annotationfolder, files(i).name));
        if isfield(v.annotation, 'folder')
            if ~strcmp(v.annotation.folder,annotationfolder)
                if nargin<3
                    v.annotation.folder = annotationfolder;
                else
                    v.annotation.folder = replacebythis;
                end
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

