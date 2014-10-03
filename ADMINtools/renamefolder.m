function renamefolder(HOMEANNOTATIONS, annotationfolder)
%
% Writes in the folder field of the xml file the nane of the folder in
% which the annotation files are.
%
% This script is useful when moving annotation files into other folders
% manually. This function guaratees consistency.

files = dir(fullfile(HOMEANNOTATIONS, annotationfolder, '*.xml'));

Nfiles = length(files);
for i = 1:Nfiles
    v = loadXML(fullfile(HOMEANNOTATIONS, annotationfolder, files(i).name));
    v.annotation.folder = annotationfolder;
    writeXML(fullfile(HOMEANNOTATIONS, annotationfolder, files(i).name), v);
end


