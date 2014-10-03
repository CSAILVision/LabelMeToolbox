function D = addcroplabel(D, words)
%
% Adds the field object.crop (it also considers an occluded object as a
% cropped object).
% 
% Removes the words 'crop', 'occluded', etc. from the object name.

if nargin < 2
    words = {'crop', 'occluded', 'part'};
end

Nwords = length(words);

for i = 1:length(D)
    if isfield(D(i).annotation, 'object')
        Nobjects = length(D(i).annotation.object);
        for j = 1:Nobjects
            if isfield(D(i).annotation.object(j), 'occluded')
                if strcmp(D(i).annotation.object(j).occluded,'yes')
                    D(i).annotation.object(j).crop = '1';
                end
            end
            
            w = lower(getwords(D(i).annotation.object(j).name));
            k = ismember(w, words);

            if sum(k)>0
                D(i).annotation.object(j).crop = '1';
                % remove words
                for n = 1:Nwords
                    D(i).annotation.object(j).name = strrep(D(i).annotation.object(j).name, words{n}, '');
                end
            else
                D(i).annotation.object(j).crop = '0';
            end
        end
    end
end

% Make sure there are no new empty object names
D = LMvalidobjects(D);


