function [class, categories] = folder2class(D)
%
% class = folder2class(D)
%
% when images are grouped into categories, and each category corresponds to
% a folder name. This function returns the class index for each image in D.
% Output:
%    class -  is an index to the folder name

for i = 1:length(D);
    f{i} = strrep(D(i).annotation.folder,'/','\');
end

[categories,b,class] = unique(f);

