function D = addparts(D, mode)
% This function looks at the parts of the object and adds them inside the
% object struct. This useful when perfoming queries.
%
% D = addparts(D)
%
% The objects will have this new fields:
% D(i).annotation.object(j).parts.object(n).name
% D(i).annotation.object(j).parts.object(n).polygon
% D(i).annotation.object(j).parts.object(n).crop
% D(i).annotation.object(j).parts.object(n).occluded
%
% This function also allows inserting the object as a part of itself. This
% might be useful in some cases... 
%
% D = addparts(D, 'addobjectasparts')

if nargin<2
    mode = '';
end

for i = 1:length(D)
    D(i).annotation = dealparts(D(i).annotation);
    
    if isfield(D(i).annotation, 'object')
        for j = 1:length(D(i).annotation.object)
            Nparts=0;
            % check that the field object is not inside already
            if ~isfield(D(i).annotation.object(j), 'parts') || ~isfield(D(i).annotation.object(j).parts, 'object')
                % chech that there are parts
                if isfield(D(i).annotation.object(j), 'parts') && isfield(D(i).annotation.object(j).parts, 'hasparts')
                    parts = D(i).annotation.object(j).parts.hasparts;
                    Nparts = length(parts);
                    
                    % insert parts
                    for n = 1:Nparts
                        D(i).annotation.object(j).parts.object(n) = D(i).annotation.object(parts(n));
                    end
                end
                
                % if option 'addobjectasparts' then add object as part
                if strcmp(mode, 'addobjectasparts')
                    D(i).annotation.object(j).parts.object(Nparts+1).name = D(i).annotation.object(j).name;
                    D(i).annotation.object(j).parts.object(Nparts+1).occluded = D(i).annotation.object(j).occluded;
                    D(i).annotation.object(j).parts.object(Nparts+1).polygon = D(i).annotation.object(j).polygon;
                    D(i).annotation.object(j).parts.object(Nparts+1).crop = D(i).annotation.object(j).crop;
                end
            end
        end
    end
end



function annotation = dealparts(annotation)

if isfield(annotation, 'object') && isfield(annotation.object(1), 'parts')
    Nobjects = length(annotation.object);
    
    ids = [annotation.object.id];
    
    for n = 1:Nobjects
        parts = annotation.object(n).parts;
        if isfield(parts, 'ispartof')
            if isnumeric(annotation.object(n).parts.ispartof)
                [foo, ispartof] = ismember(annotation.object(n).parts.ispartof, ids);
            else
                [foo, ispartof] = ismember(str2num(annotation.object(n).parts.ispartof), ids);
            end
            annotation.object(n).parts.ispartof = ispartof;
        end
        
        if isfield(parts, 'hasparts')
            if isnumeric(annotation.object(n).parts.hasparts)
                [foo, hasparts] = ismember(annotation.object(n).parts.hasparts, ids);
            else
                [foo, hasparts] = ismember(str2num(annotation.object(n).parts.hasparts), ids);
            end
            hasparts = setdiff(hasparts, 0);
            annotation.object(n).parts.hasparts = hasparts;
        end
    end

end
