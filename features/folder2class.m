function [class, categories] = folder2class(D, foldernames, categories)
%
% [class, categories] = folder2class(D)
%
% when images are grouped into categories, and each category corresponds to
% a folder name. This function returns the class index for each image in D.
% Output:
%    class -  is an index to the folder name
%    categories - list of folder names (indexed by class)
%
%
% If you want to assign images in certain folders to predefined categories,
% you can do this:
%
% First, create cell arrays indicating which folders will go inside each
% category:
%   desert = {'b\badlands', 'd\desert\sand', 'd\desert\vegetation', 'o\oasis'};
%   seacoast = {'b\beach', 'b\beach_house', 'c\coast', 'o\ocean', 's\sandbar'};
%
% The call folder2class:
%   [class, categories] = folder2class(Dsun, {desert, seacoast}, {'desert', 'seacoast'});
%
% Output:
%    class -  is an index to the each category
%

% A. Torralba


if nargin == 1
    for i = 1:length(D)
        f{i} = strrep(D(i).annotation.folder,'/','\');
    end
    
    [categories,b,class] = unique(f);
else
    class = zeros([1 length(D)]);
    for i = 1:length(D)
        f = strrep(D(i).annotation.folder,'/','\');
        for c = 1:length(foldernames)
            if ismember(f, foldernames{c})
                class(i)=c;
            end
        end
    end
end

