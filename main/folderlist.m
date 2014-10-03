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
    if Nfolders >1
        for i = 1:Nfolders
            tmp = folders(h(i)+1:h(i+1)-1);
            tmp = strrep(tmp, HOME, '');
            if ~isempty(tmp)
                if strcmp(tmp(1), filesep)
                    tmp = tmp(2:end);
                end
                
                %ii = ii+1;
                folder{i} = tmp;
            else
                folder{i} = '.';
            end
        end
    else
        folder{1} = '.';
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

folder = {HOME};
expandable = 1;

while sum(expandable)
    j = find(expandable);
    for n = 1:length(j)
        disp(['* expanding: ' folder{j(n)}])
        expanded_list = geturlfolderlist(folder{j(n)});
        
        expandable(j(n))=0;
        if ~isempty(expanded_list)
            folder = [folder expanded_list];
            expandable = [expandable ones(1,length(expanded_list))];
        end
    end
end


% 
% 
% % get folder list from a URL
% [folder, status] = geturlfolderlist(HOME);
% 
% if ~ismepty(folder)
%     folder = folder;
%     for n = 1:length(folder)
%         folder2 = urlfolderlist(folder{n});
%         folder_final = [folder_final folder2];
%     end
% else
%     folder = HOME;
% end
% folder = [HOME folder_final];
% 
% 
% keyboard
% 
% % recursion
% folder_final = {};
% for n = 1:length(folder)
%     folder2 = urlfolderlist(folder{n});
%     folder_final = [folder_final folder2];
% end
% folder = [HOME folder_final];
% 
% 
function [folder, status] = geturlfolderlist(HOME)


if strcmp(HOME(end), '/')
    HOME = HOME(1:end-1);
end


folder = {};
status=0;
while status == 0
    [files,status] = urldir(HOME, 'DIR');
    if status == 0
        disp(sprintf('Warning: Failure urldir %s. Trying again...',HOME))
        drawnow
    end
end

if status == 1
    for n = 1:length(files)-1
        folder{n} = [HOME '/' files(n+1).name]; % the first item is the main path name
        disp(folder{n})
    end
end



