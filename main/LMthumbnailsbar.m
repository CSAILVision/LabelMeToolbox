function LMthumbnailsbar(folderlist, filelist, pagename, HOMEIMAGES);
%
% LMthumbnailsbar(folderlist, filelist, pagename, HOMEIMAGES);
%
% HOMEIMAGES should be the path for the images in your local copy of the
% database.
%
% This function allows building an interface that communicates with the
% LabelMe web annotation tool. 
%
% It can be used to label specific images. It adds a bar with thumbnails at
% the left side of the annotation tool. 
% 
% You can use this to label images that have some characteristic that you
% want. You can use this function in combination with the LMquery function.
%
% For instance, if you want to create a web page with images only of
% kitchens so that the thumbnails are connected to the LabelMe web
% annotation tool online, you can do the next thing:
%
% [D,j] = LMquery(database, 'folder', 'kitchen');
% for i = 1:length(D);
%    folderlist{i} = D(i).annotation.folder;
%    filelist{i} = D(i).annotation.filename;
% end
% LMthumbnailsbar(folderlist, filelist, 'myphotoalbum.html', HOMEIMAGES);
%
%
% See also LMphotoalbum
%

Nimages = length(folderlist);
webpage = 'http://labelme.csail.mit.edu/tool.html?collection=LabelMe&mode=i'
thumbpage = 'http://people.csail.mit.edu/brussell/research/LabelMe/Thumbnails/'

% Header
page = {};

% Create links for each image
for i = 1:Nimages
    imageline = sprintf('<IMG src="%s/%s/%s" width=120 border=2>', thumbpage, folderlist{i}, filelist{i});
    page = addline(page, sprintf('%d<br>',i));
    page = addline(page, ...
        [sprintf('<a href="%s&folder=%s&image=%s" target="labelme">%s</a>', ...
        webpage, folderlist{i}, filelist{i}, imageline)]);
end

% Close web page
page = addline(page, '</body></html>');

% write web page
fid = fopen(['bar' pagename],'w');
for i = 1:length(page); 
    fprintf(fid, [page{i} '\n']); 
end
fclose(fid);

% Header
page = {};
page = addline(page, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"');
page = addline(page, '"http://www.w3.org/TR/html4/frameset.dtd">');
page = addline(page, '<html><head><title>LabelMe thumbnail bar</title></head>');
page = addline(page, '<FRAMESET cols="154, *">');
page = addline(page, sprintf('<FRAME src="%s">', ['bar' pagename]));
page = addline(page, sprintf('<FRAME src = "%s&folder=%s&image=%s" name="labelme">', webpage, folderlist{1}, filelist{1}));
page = addline(page, '</FRAMESET></html>');

% write web page
fid = fopen(pagename,'w');
for i = 1:length(page); 
    fprintf(fid, [page{i} '\n']); 
end
fclose(fid);

function page = addline(page, line)

page = [page {line}];
