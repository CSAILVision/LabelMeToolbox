function D = addoccludedtag(D, words)
%
% Adds the field object.crop (it also considers an occluded object as a
% cropped object).
% 
% Removes the words 'occluded' from the object name.

if nargin < 2
    words = {'occluded'};
end

Nwords = length(words);
changes = 0;

for i = 1:length(D)
    if isfield(D(i).annotation, 'object')
        Nobjects = length(D(i).annotation.object);
        for j = 1:Nobjects
            
%             if isfield(D(i).annotation.object(j), 'occluded')
%                 D(i).annotation.object(j).occluded == 'yes'
%             end
            
            w = lower(getwords(D(i).annotation.object(j).name));
            k = ismember(w, words);

            if sum(k)>0
                D(i).annotation.object(j).occluded = 'yes';
                changes = changes + 1;
                % remove words
                for n = 1:Nwords
                    D(i).annotation.object(j).name = strrep(D(i).annotation.object(j).name, words{n}, '');
                end
            end
        end
    end
end

% Make sure there are no new empty object names
D = LMvalidobjects(D);

fprintf('occluded field: %d changes to ''yes''\n', changes')

