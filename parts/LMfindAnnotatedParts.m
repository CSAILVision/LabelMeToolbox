function [Dwithparts, j, objectPartStatistics] = LMfindAnnotatedParts(D)
%
% Find all the images that have at least one object with annotated parts
%
% Returns the following structure:
%     objectPartStatistics(i).object_name: name of object
%     objectPartStatistics(i).object_count: number of instances in D of this object
%     objectPartStatistics(i).parts: all the parts combination of the object
%             objectPartStatistics(i).parts(j).part_names: list of parts combination 
%             objectPartStatistics(i).parts(j).count: number of instances that have the j-th parts combination


j = zeros([1,length(D)]);
Dwithparts = D;
for i = 1:length(D)
    m = [];
    for k = 1:LMcountobject(D(i))
        if isfield(D(i).annotation.object(k),'parts')
            if isfield(D(i).annotation.object(k).parts,'ispartof') && ~isempty(D(i).annotation.object(k).parts.ispartof)
                j(i) = 1;
                m = [m k];
            end
            if isfield(D(i).annotation.object(k).parts,'hasparts')
                j(i) = 1;
                m = [m k];
            end
        end
    end
    if ~isempty(m)
        Dwithparts(i).annotation.object = Dwithparts(i).annotation.object(m);
    end
end

j = find(j);
Dwithparts = Dwithparts(j);

