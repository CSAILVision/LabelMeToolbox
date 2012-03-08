function folder = folderlist(HOME, subfolder)
%
% Return list of folders inside HOME
%
% folder = folderlist(HOME)
%   folder = cell array
%
% HOME can also be an URL address

if strcmp(HOME(end), filesep)
    HOME = HOME(1:end-1);
end

if ~strcmp(HOME(1:4), 'http')
    if nargin == 1
        folders = genpath(HOME);
    else
        folders = genpath(fullfile(HOME, subfolder));
    end
    
    h = [findstr(folders,  pathsep)];
    h = [0 h];
    Nfolders = length(h)-1;
    ii = 0;
    folder = {};
    for i = 1:Nfolders
        tmp = folders(h(i)+1:h(i+1)-1);
        tmp = strrep(tmp, HOME, '');
        if ~isempty(tmp)
            if strcmp(tmp(1), filesep)
                tmp = tmp(2:end);
            end
            
            ii = ii+1;
            folder{ii} = tmp;
        end
    end
else
    if nargin == 1
        folders = urlfolderlist(HOME);
    else
        folders = urlfolderlist([HOME '/' subfolder]);
    end
    Nfolders = length(folders);
    
    folder = {};
    ii = 0;
    for i = 1:Nfolders
        tmp = strrep(folders{i}, HOME, '');
        
        if ~isempty(tmp)
            ii = ii+1;
            folder{ii} = tmp;
        end
    end 
end




function folder = urlfolderlist(HOME)
% get folder list from a URL
[folder, status] = geturlfolderlist(HOME);

% recursion
folder_final = {};
for n = 1:length(folder)
    folder2 = urlfolderlist(folder{n});
    folder_final = [folder_final folder2];
end
folder = [HOME folder_final];


function [folder, status] = geturlfolderlist(HOME)


if strcmp(HOME(end), '/')
    HOME = HOME(1:end-1);
end

folder = {};
[files,status] = urldir(HOME, 'DIR');
if status == 1
    for n = 1:length(files)-1
        folder{n} = [HOME '/' files(n+1).name]; % the first item is the main path name
    end
end




