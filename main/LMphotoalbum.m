function LMphotoalbum(varargin)
%
% LMphotoalbum(D, pagename);
%
% or
%
% for i = 1:length(D);
%    folderlist{i} = D(i).annotation.folder;
%    filelist{i} = D(i).annotation.filename;
% end
% LMphotoalbum(folderlist, filelist, pagename);
%
% This function allows building an interface that communicates with the
% LabelMe web annotation tool.
%
% It can be used to label specific images.
%
% You can use this to label images that have some characteristic that you
% want. You can use this function in combination with the LMquery function.
%
% For instance, if you want to create a web page with images only of
% kitchens so that the thumbnails are connected to the LabelMe web
% annotation tool online, you can do the next thing:
%
% [D,j] = LMquery(D, 'folder', 'kitchen');
% LMphotoalbum(D, 'myphotoalbum.html');
%
% This will create a web page with thumbnails of the selected images. But
% more importantly, the images will be link with the LabelMe online tool.
% So, whenever you will click on one image it will call the annotation tool
% and will open that specific image showing the annotations available
% online (not the local ones that you have). Now you can label more objects
% in that image and download later the annotations.


if nargin == 2
    D = varargin{1};
    pagename   = varargin{2};
    for i = 1:length(D)
        folderlist{i} = D(i).annotation.folder;
        filelist{i} = D(i).annotation.filename;
    end
    ADDSUMMARY = 1;
end
if nargin > 2
    folderlist = varargin{1};
    filelist   = varargin{2};
    pagename   = varargin{3};
    ADDSUMMARY = 0;
end

ADDSUMMARY = 0;


Nimages = length(folderlist);
webpage = 'http://labelme.csail.mit.edu/Release3.0/tool.html?mode=i';

l = max(findstr(pagename,'/'));
if ~isempty(l)
    htmlname = pagename(l+1:end);
else
    htmlname = pagename;
end

Npages = 100;
chunk = fix(linspace(0, Nimages, Npages+1));

for pp = 1:Npages
    
    % Hearder
    page = {};
    page = addline(page, '<html><head><title>LabelMe photoalbum</title><body>');
    if Npages > 1
        page = addline(page, '<img src="http://labelme.csail.mit.edu/Icons/LabelMeNEWtight198x55.gif" height=26 alt="LabelMe" />');
        for k = 1:Npages
            kpage = strrep(htmlname,'.html',sprintf('%d.html', k));
            page = addline(page, sprintf('| <a href="%s">%d</a>', kpage, k));
        end
        nextpage = strrep(htmlname,'.html',sprintf('%d.html', pp+1));
        page = addline(page, sprintf(' | <a href="%s">next', nextpage));
        page = addline(page, '</a> |<br>');
        page = addline(page, sprintf('page: %d <br>', pp));
    else
        page = addline(page, '<img src="http://labelme.csail.mit.edu/Icons/LabelMeNEWtight198x55.gif" height=26 alt="LabelMe" /><br>');
    end
    
    if ADDSUMMARY
    Dpage = D(chunk(pp)+1:chunk(pp+1));
        [names, counts]  = LMobjectnames(Dpage);
        [foo, ndxn] = sort(-counts);
        names = names(ndxn);
        counts = counts(ndxn);
        
        page = addline(page, '<b>Database summary:</b><br>');
        page = addline(page, sprintf('There are %d images<br>', Nimages));
        page = addline(page, sprintf('There are %d polygons<br>', sum(counts)));
        page = addline(page, sprintf('There are %d descriptions<br>', length(names)));
        page = addline(page, sprintf('Last update: %s<br>', date));
        page = addline(page, ' List of objects:<br>');
        page = addline(page, '<div style="width:800px;height:100px;overflow-y:scroll;overflow-x:none;border:thin solid;">');
        for no = 1:length(names)
            page = addline(page, sprintf('<li> %s (%d instances)<br>', names{no}, counts(no)));
        end
        
        page = addline(page, '</div>');
        page = addline(page, '<br><hr align="Left" size="1">');
        
    else
        page = addline(page, '<b><font size=5> Photoalbum</font></b><br>');
        page = addline(page, '<hr align="Left" size="1"><br>');
        page = addline(page, sprintf('<b><font size=4>There are %d images.</font></b><br>', Nimages));
        page = addline(page, '<b><font size=4>Click on an image to open it with LabelMe</font></b><br>');
    end
    
    % Create links for each image
    for i = chunk(pp)+1:chunk(pp+1)
        %imageline = sprintf('<IMG src="http://labelme2.csail.mit.edu/Release3.0/Thumbnails/%s/%s" border=2>', ...
        %    folderlist{i}, filelist{i});
        imageline = sprintf('<iframe src="http://labelme2.csail.mit.edu/Release3.0/browserTools/php/plotThumbnail.php?folder=%s&image=%s&index=%d" HEIGHT=180 width=200 marginheight="0" marginwidth="0" frameborder="0" scrolling="no" seamless="seamless"></iframe>', ...
            folderlist{i}, filelist{i}, i);

            %[sprintf('%d) <a href="%s&folder=%s&image=%s" target="_blank">%s</a>', ...
        page = addline(page, sprintf('%s', imageline));        
        %page = addline(page, ...
        %    [sprintf('%d) <a href="%s&folder=%s&image=%s" target="_blank">%s</a>', ...
        %    i, webpage, folderlist{i}, filelist{i}, imageline)]);
    end
    page = addline(page, '<hr align="Left" size="1"><br>');
    
    % Close web page
    page = addline(page, '</body></html>');
    
    % write web page
    if Npages>1
        fid = fopen(strrep(pagename,'.html',sprintf('%d.html', pp)),'w');
    else
        fid = fopen(pagename,'w');
    end
    
    for i = 1:length(page);
        fprintf(fid, [page{i} '\n']);
    end
    fclose(fid);
end

function page = addline(page, line)

page = [page {line}];
