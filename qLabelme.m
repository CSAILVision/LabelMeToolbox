function [img, seg] = qLabelme(query, Nmax, imageHeight)
%
% This function performs a query using the online tool. 
% The output is a collection of crop objects and the segmentation masks
%
% Objects are 128 pixels high, width varies.
% 
% [img, seg] = cell arrays

if nargin == 1
    Nmax = 100000;
end

query = strrep(query, ' ', '%20');

webquery = 'http://people.csail.mit.edu/torralba/research/LabelMe/js/LabelMeQueryObjectFast.cgi/?query=QUERY'
webquery = strrep(webquery, 'QUERY', query); 
[s, STATUS] = urlread(webquery);
page = 'http://people.csail.mit.edu/brussell/research/LabelMe/ThumbnailsObjects';

taginit = 'ThumbnailsObjects';
jinit = strfind(s, taginit);
jend = strfind(s, '"');

M = min(length(jinit), Nmax);
for j = 1:M
    disp(sprintf('Downloading %d / %d', j, M))
    
    % Link to full res image:
    je = min(jend(find(jend>jinit(j)+length(taginit))));
    q = s(jinit(j)+length(taginit):je-1);

    url = [page q];

    thumb = imread(url);
    [nrows ncols cc] = size(thumb);
    thumb = thumb(:,1:ncols-mod(ncols,2),:);
    [nrows ncols cc] = size(thumb);    
    
    img{j} = thumb(:,1:fix(ncols/2),:);
    seg{j} = max(thumb(:,fix(ncols/2)+1:ncols,:),[],3)>128;
    
    if nargin == 3
        img{j} = imresize(img{j}, imageHeight/size(img{j},1), 'bicubic');
        seg{j} = imresize(seg{j}, imageHeight/size(seg{j},1), 'bicubic')>0;
    end
    
    %scaling = M/min([size(img,1) size(img,2)]);
    %newsize = round([size(img,1) size(img,2)]*scaling);
    %img = imresize(img, newsize, METHOD, 41);    
    
    size(img{j})
    size(seg{j})
    
    if nargout == 0
        % display
        figure(ceil(j/49))
        subplottight(7,7,j)
        imshow(uint8(double(img{j}).*double(repmat(seg{j},[1 1 3]))))
        drawnow
    end
end

