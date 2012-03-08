function D = LMreplaceobjectname(D, name1, name2, method)
% Replace an object name by another name.
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

if nargin < 4
    method = 'replace';
end

name1 = lower(name1);
name2 = lower(name2);

[d, j] = LMquery(D, 'object.name', name1);
clear d

Nimages = length(j);
for n = 1:Nimages
    %Nobjects = length(D(j(n)).annotation.object);
    jc = LMobjectindex(D(j(n)).annotation, name1);
    
    for m = jc
        currentname = lower(D(j(n)).annotation.object(m).name);
        switch method
            case 'replace'
                % replace each substring name1 by name2
                D(j(n)).annotation.object(m).name = strrep(currentname, name1, name2);
            case 'rename'
                % rename the object
                D(j(n)).annotation.object(m).name = name2;
        end
    end
end

disp(sprintf('%d entries replaced', Nimages))
