function Dwhole = removeparts(D)
% D = removeparts(D)
%


Dwhole = [];

n = 0;
for i = 1:length(D)    
    if isfield(D(i).annotation, 'object')
        w = [];
        for j = 1:length(D(i).annotation.object)
            if isfield(D(i).annotation.object(j), 'parts') && isfield(D(i).annotation.object(j).parts, 'ispartof')
            else
                w = [w j];
            end
        end
        
        if ~isempty(w)
            n = n+1;
            Dwhole(n).annotation = D(i).annotation;
            Dwhole(n).annotation.object = Dwhole(n).annotation.object(w);
        end
    end
end

