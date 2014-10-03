function [D, j, key] = LMquery(D, fieldName, content, method)
%
% This function provides basic query functionalities. It allows you to
% locate images with certain objects.
%
% [Dout, j, key] = LMquery(D, fieldName, content, method)
%
%    D:         database struct
%    fieldName: can be any of the fields in the struct at the object level.
%    content:   a string describing the desired field you are looking for.
%               you can use the characters '+' and '-' within the content string in
%               order to perform 'and' and 'not' operations.
%    method:    when selected 'exact', the content must be match exactly
%             Methods:
%               [] = default = substring matching (air => chair)
%               'exact' = strings should match exactly
%               'word'  = the field should match words (air ~=> chair) 
% 
% Output:
%   Dout: new struct matching the query
%   j: indices to images that fit the query. Note Dout is not D(j). D(j)
%   contains all the objects in the original struct
%   key: pointers to images and objects in Dout with respect to D.
%       The first image in Dout is:
%         D(key(1).jimg).annotation.object(key(1).jobj)
%      [key(:).jimg] is the same as j
%
%
% The function LMquery searchs for images in the database.
% Queries can be done on any field of the struct array.
% The fields for an image are:
%    filename
%    folder
%    source.sourceImage
%    source.sourceAnnotation
%    object(:).name
%    object(:).deleted
%    object(:).verified
%    object(:).date
%    object(:).polygon.username
%    object(:).polygon.pt(:).x
%    object(:).polygon.pt(:).y
%    object(:).viewpoint.azimuth
%
% Look at the results of these two lines (HOMEIMAGES should be set with the path of the database):
% LMdbshowobjects(LMquery(D, 'object.name', 'plate+license'), HOMEIMAGES);
% LMdbshowobjects(LMquery(D, 'object.name', 'plate-license'), HOMEIMAGES);
%
% Performs an OR function. This will select objects that belong to one of this groups: 1) side views
% of cars, 2) buildings 3) roads or 4) trees.
% [D,j] = LMquery(D, 'object.name', 'car+side,building,road,tree');
%
% To make AND queries of different objects within an image, you can chain several queries. 
% For instance, to get images that have cars, buildings and roads:
%    [Dfoo,j1] = LMquery(D, 'object.name', 'building');
%    [Dfoo,j2] = LMquery(D, 'object.name', 'road');
%    j = intersect(j1,j2);
%    LMshow(LMquery(D(j), 'object.name', 'car,building,road'));
%
% You can query other fields. The next lines allow you to select from the
% database, all the polygons that have been verified and that are not
% marked as deleted. This is something you might want to do often:
%    D = LMquery(D, 'object.verified', '1');
%    D = LMquery(D, 'object.deleted', '0');
%
% or D = LMquery(LMquery(D, 'object.verified', '1'), 'object.deleted', '0');
%
% You can also query based on the date of annotation:
%    LMshow(LMquery(database, 'date', '13-Jan'));
% [in the case of dates, D is an exception about the meaning of the
% character '-'. Here is just a separation between day and month].
%
% More examples:
% Queries for objects
% [Dj,j] = LMquery(D, 'object.name', 'building');
% LMdbshowscenes(D(j), HOMEIMAGES); % this shows all the objects in the images that contain buildings
% LMdbshowscenes(Dj, HOMEIMAGES); % this shows only the buildings
%
% Queries for images in specific folders. 
% [Dj,j] = LMquery(D, 'folder', '05june05_static_indoor');
% LMdbshowscenes(D(j), HOMEIMAGES); % this shows all the objects
%
% The next example shows the annotated objects from images that come from the web:
% [Dj,j] = LMquery(D, 'folder', 'web');
% LMdbshowscenes(D(j), HOMEIMAGES); % this shows all the objects
%
% look for a specific image file:
% [Dj,j] = LMquery(D, 'filename', 'p1010843.jpg');
% LMdbshowscenes(D(j), HOMEIMAGES); % this shows all the objects
%
% look for objects annotated by one user:
% [Dj,j] = LMquery(D, 'object.polygon.username', 'atb');
% LMdbshowscenes(Dj, HOMEIMAGES); % this shows all the objects annotated by one user
%
% look for objects by viewpoint:
% [D,j] = LMquery(D, 'object.viewpoint.azimuth', '0', 'exact');
%

if (nargin < 4)
    method = '';
end

% Parse query
%if length(strfind(fieldName, 'date'))>0
%    query{1} = {['+' lower(content)]};
%else
%    query = parseContent(content);
%end

% Parse query
if ~isempty(strfind(fieldName, 'date')) || strcmp(method,'exact')
    query{1} = {['+' lower(content)]};
%elseif strcmp(method,'exact')
%    query{1} = {['+' lower(content)]};
else
    query = parseContent(content);
end


% Parse queried field
fieldName = ['annotation.' fieldName];
fieldName = parseContent(fieldName, '.');

% Locate the images that verify the query
Nimages = length(D);
queriedImages = logical(zeros(Nimages,1));

k=0;
for i = 1:Nimages
    v = D(i);
    
    [vn, jc] = queryfields(v, fieldName, query, method);

    if ~isempty(vn)
        queriedImages(i)=1;
        D(i) = vn;
        
        k = k + 1;
        key(k).jimg = i;
        key(k).jobj = jc;
    end
end

disp(sprintf('%d matches out of %d', sum(queriedImages), length(D)))

D = D(queriedImages);
j = find(queriedImages);


function [vn, jc] = queryfields(v, fieldName, query, method)

vn = [];
jc = [];
depthfield = length(fieldName);

if depthfield == 1
    % End recursion
    if isfield(v, fieldName{1}{1}(2:end))
        jc = findobject({v.(fieldName{1}{1}(2:end))}, query, method);
        vn = v(jc);
    else
        if strcmp(query{1}(1), '-')
            jc = 1:length(v);
            vn = v;
        end
    end
else
    if isfield(v, fieldName{1}{1}(2:end))
        % Recursive call
        N = length(v);
        q = logical(zeros(N,1));
        for i = 1:N
            vi = getfield(v, {i}, fieldName{1}{1}(2:end));
            [vi, jc] = queryfields(vi, fieldName(2:end), query, method);
            q(i) = ~isempty(vi);
            v(i).(fieldName{1}{1}(2:end)) = vi;
        end
        jq = find(q);
        vn = v(jq);
    else
        if strcmp(query{1}(1), '-')
            jc = 1:length(v);
            vn = v;
        end
    end
end


