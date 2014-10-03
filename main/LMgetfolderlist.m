function folderlist = LMgetfolderlist();
%
% Downloads the full list of folders from the online LabelMe dataset.
%  folderlist = LMgetfullfolderlist()
%
% This is useful for performing LMinstall, etc.
%

webpageanno = 'http://people.csail.mit.edu/brussell/research/LabelMe/Annotations'
folderlist = urldir(webpageanno, 'DIR');
folderlist = {folderlist(2:end).name};

for i = 1:length(folderlist)
    folderlist{i} = folderlist{i}(1:end-1);
end
