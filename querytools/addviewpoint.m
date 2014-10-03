function D = addviewpoint(D)
% Adds to the object name a label that describes the viewpoint

% add view point into the object name
for i = 1:length(D)
    if isfield(D(i).annotation, 'object')
        for j = 1:length(D(i).annotation.object)
            if isfield(D(i).annotation.object(j), 'viewpoint')
                if ~isempty(D(i).annotation.object(j).viewpoint)
                    a = str2num(D(i).annotation.object(j).viewpoint.azimuth);
                    D(i).annotation.object(j).name = [strtrim(D(i).annotation.object(j).name) sprintf(' az%ddeg', a)];
                end
            end
        end
    end
end
