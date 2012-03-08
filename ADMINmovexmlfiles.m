function ADMINmovexmlfiles(ORIGINALFOLDER, DESTFOLDER)
%
% ADMINmovexmlfiles(ORIGINALFOLDER, MIRRORFOLDER)
%
% Asumes that the destination already has the right folder structure. This
% function will not create folders
% 
% 

% Create list of folders
folders = genpath(ORIGINALFOLDER);
h = findstr(folders,  pathsep);
h = [0 h];
Nfolders = length(h)-1;
for i = 1:Nfolders
    tmp = folders(h(i)+1:h(i+1)-1);
    tmp = strrep(tmp, ORIGINALFOLDER, ''); tmp = tmp(2:end);
    Folder{i} = tmp;
end


% move xml
for f = 1:Nfolders
    xmlfiles = dir(fullfile(ORIGINALFOLDER, Folder{f}, '*.xml'));
    xmlfiles = {xmlfiles(:).name};
    
    if ~isempty(xmlfiles)
        mkdir(fullfile(DESTFOLDER, Folder{f}))
        cmd = sprintf('mv %s %s', fullfile(ORIGINALFOLDER, Folder{f}, '*.xml'), fullfile(DESTFOLDER, Folder{f}))
        
        dos(cmd)
    end
end
