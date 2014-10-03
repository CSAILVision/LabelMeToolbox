function [names, counts, imagendx, objectndx, descriptionndx] = LMobjectnames(D, field)
% Returns the name of all the object classes in the database, 
% and the number of instances of each object class:
%
% [names, counts] = LMobjectnames(D);
%
% You can visualize the counts and object names by calling the function
% without output arguments:
%
% LMobjectnames(D);
%
% You can see the list of words associated with an object class using the
% command LMobjectnames. Some examples:
%   LMobjectnames(LMquery(D, 'name', 'face'))
%   LMobjectnames(LMquery(D, 'name', 'plate'))
%   LMobjectnames(LMquery(D, 'name', 'person'))
%
% [names, counts, imagendx, objectndx, descriptionndx] = LMobjectnames(D);

Nannotations = length(D);
Npolygons = countpolygons(D);
names = {};
imagendx = zeros(Npolygons,1);
objectndx = zeros(Npolygons,1);
descriptionndx = zeros(Npolygons,1);

if nargin == 1
    for i = 1:Nannotations
        if isfield(D(i).annotation, 'object')
            names = union(names, strtrim(lower({D(i).annotation.object(:).name})));
        end
    end
        
    m = 0;
    for i = 1:Nannotations
        %if mod(i,100)==0; disp(i); end
        
        if isfield(D(i).annotation, 'object')
            N = length(D(i).annotation.object);

            [food, descriptionndx(m+1:m+N)] = ismember(strtrim(lower({D(i).annotation.object(:).name})), names);
            
            imagendx(m+1:m+N) = i;
            objectndx(m+1:m+N) = 1:N;
            m = m + N;
            %for j = 1:N
            %    m = m +1;
                %descriptionndx(m) = strmatch(strtrim(lower(D(i).annotation.object(j).name)), names, 'exact');
                
                %names{m} = D(i).annotation.object(j).name;
            %    imagendx(m) = i;
            %    objectndx(m) = j;
                
            %end
        end
    end
    
    %[foo, i, descriptionndx] = unique(strtrim(lower(names)));
    %names = strtrim(names(i));    
else
    
    m = 0;
    
    for i = 1:Nannotations
        if mod(i,100)==0; disp(i); end
        
        if isfield(D(i).annotation, 'object')
            if isfield(D(i).annotation.object, field)
                N = length(D(i).annotation.object);
                for j = 1:N
                    if ~isempty(D(i).annotation.object(j).(field))
                        m = m +1;
                        names{m} = D(i).annotation.object(j).(field);
                        imagendx(m) = i;
                        objectndx(m) = j;
                    end
                end
            end
        end
    end
    [foo, i, descriptionndx] = unique(strtrim(lower(names)));
    names = strtrim(names(i));
    
end

imagendx = imagendx(1:m);
objectndx = objectndx(1:m);


if nargout ~= 1 || nargin == 2
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
    if nargin == 1
        disp('Sorted list of object names')
    else
        disp(['Sorted list of ' field])
    end
    disp('-------------------------------------------')
    disp(sprintf(' Index|\t Counts\t|Name'));

    for i = 1:length(jj)
        disp(sprintf('%5d |\t%7d\t|%s', i, counts(jj(i)), names{jj(i)}));
    end
end
