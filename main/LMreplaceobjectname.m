function D = LMreplaceobjectname(D, name1, name2, method)
% Replace an object name by another name.
%   D = LMreplaceobjectname(D, name1, name2, method)
%    
%    method = replace, rename, exact(default)
%
%  rename and replace search for objects with the substring name1. 'exact'
%  only allows for exact matches.
%
% It is not case sensitive.
%
% D = LMreplaceobjectname(D, 'person walking', 'pedestrian')
%
% Reemplaces all the object names that contain the string 'person' by the
% short name 'person'
% D = LMreplaceobjectname(D, 'person', 'person', 'rename')
%
% Reemplaces all the object names that contain the strings 'person' or 'pedestrian' by the
% short name 'person'
% D = LMreplaceobjectname(D, 'person,pedestrian', 'person', 'rename')
%
% It does not modify the annotation files. It only modifies the index
% struct.
%
% If name2 is empty it will delete the objects.

if nargin < 4
    method = 'exact';
end

name1 = lower(name1);
name2 = lower(name2);

switch method
    case 'replace'
        [~, j] = LMquery(D, 'object.name', name1);
    case 'rename'
        [~, j] = LMquery(D, 'object.name', name1);
    case 'exact'
        [~, j] = LMquery(D, 'object.name', name1, 'exact');
end


Nimages = length(j);
for n = 1:Nimages
    %Nobjects = length(D(j(n)).annotation.object);
    switch method
        case 'replace'
            jc = LMobjectindex(D(j(n)).annotation, name1);
        case 'rename'
            jc = LMobjectindex(D(j(n)).annotation, name1);
        case 'exact'
            jc = LMobjectindex(D(j(n)).annotation, name1, 'exact');
    end
    
    for m = jc(:)'
        currentname = lower(D(j(n)).annotation.object(m).name);
        switch method
            case 'replace'
                % replace each substring name1 by name2
                D(j(n)).annotation.object(m).name = strrep(currentname, name1, name2);
            case 'rename'
                % rename the object
                D(j(n)).annotation.object(m).name = name2;
            case 'exact'
                % rename the object
                fprintf('Replace ''%s'' with ''%s'' \n', D(j(n)).annotation.object(m).name, name2);
                D(j(n)).annotation.object(m).name = name2;
                
                if isempty(name2)
                    disp('marked as deleted')
                    D(j(n)).annotation.object(m).deleted='1';
                end
        end
    end
end

%D = LMvalidobjects(D);

disp(sprintf('%d entries replaced', Nimages))

