function [names, counts] = LMpartnames(D,object_name,method)

% Returns the name of all the objects in the database that are parts of 
% some other object, and the number of instances of each object class:
%
% [names, counts] = LMpartnames(D);
%
% You can visualize the counts and object names by calling the function
% without output arguments:
%
% LMpartnames(D);
%
% You can see the list of words associated with an object class using the
% command LMobjectnames. Some examples:
%   LMpartnames(LMquery(D, 'name', 'face'))
%   LMpartnames(LMquery(D, 'name', 'plate'))
%   LMpartnames(LMquery(D, 'name', 'person'))
%
% If there is the input object_name it returns just the name of parts of 
% that object. If method is 'exact', the name of the object must be match 
% exactly object_name


% if parts are not added in D, add them
has_partsadded = 0;
decision = 0;
i = 1;
while decision == 0
    if isfield(D(i).annotation, 'object')
        if isfield(D(i).annotation.object,'parts')
            j = 1;
            decision = 1;
            if isfield(D(i).annotation.object(j).parts,'hasparts')
                has_parts_added = 1;
            else
                has_parts_added = 0;
            end
        end
    end
    i = i + 1;
end
if has_parts_added == 0
    D = addparts(D);
end

% get just objects of class name_objects (if we have 2 inputs)
if nargin > 1
    if nargin == 2
        method = 'exact';
    end
    D = LMquery(D,'object.name',object_name,method);
end

Nannotations = length(D);
Npolygons = countpolygons(D);
names = {};
imagendx = zeros(Npolygons,1);
objectndx = zeros(Npolygons,1);
descriptionndx = zeros(Npolygons,1);

for i = 1:Nannotations
    if isfield(D(i).annotation, 'object')
        if isfield(D(i).annotation.object,'parts')
            for j = 1:length(D(i).annotation.object)
                if isfield(D(i).annotation.object(j).parts,'object')
                    if nargin == 1
                        names = union(names, strtrim(lower({D(i).annotation.object(j).parts.object(:).name})));
                    else
                        if strcmp(D(i).annotation.object(j).name,object_name)
                            names = union(names, strtrim(lower({D(i).annotation.object(j).parts.object(:).name})));
                        end
                    end
                end
            end
        end
    end
end
m = 0;
for i = 1:Nannotations
    %if mod(i,100)==0; disp(i); end
    if isfield(D(i).annotation, 'object')
        if isfield(D(i).annotation.object,'parts')
            for j = 1:length(D(i).annotation.object)
                if isfield(D(i).annotation.object(j).parts,'object')
                    
                    N = length(D(i).annotation.object(j).parts.object);
                    [food, descriptionndx(m+1:m+N)] = ismember(strtrim(lower({D(i).annotation.object(j).parts.object(:).name})),names);
                    imagendx(m+1:m+N) = i;
                    objectndx(m+1:m+N) = 1:N;
                    m = m + N;                    
                end
            end
        end
    end
end

imagendx = imagendx(1:m);
objectndx = objectndx(1:m);


if nargout ~= 1 
    Nobject = length(names);
    [counts, x] = hist(descriptionndx, 1:Nobject);
end

if nargout == 0
    % plot counts
    [foo,jj] = sort(counts, 'descend');
    figure
    barh(counts(jj))
    set(gca, 'YTick', 1:Nobject)
    set(gca, 'YtickLabel', names(jj))
    axis([0 max(counts)+5 0 Nobject+1])
    grid on
    
    disp(' ')
    
    disp('Sorted list of object names')
    
    disp('-------------------------------------------')
    disp(sprintf(' Index|\t Counts\t|Name'));
    
    for i = 1:length(jj)
        disp(sprintf('%5d |\t%7d\t|%s', i, counts(jj(i)), names{jj(i)}));
    end
end