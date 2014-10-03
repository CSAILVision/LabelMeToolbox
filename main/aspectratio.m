function [ar, name] = aspectratio(D)
%
% ar = height / width

k = 0;
for i = 1:length(D);
    if isfield(D(i).annotation, 'object')
        Nobjects = length(D(i).annotation.object);
        
        for n = 1:Nobjects
            [X,Y] = getLMpolygon(D(i).annotation.object(n).polygon);

            k = k+1;
            ar(k) = abs((max(Y)-min(Y))/(0.00001+max(X)-min(X)));
            name{k} = D(i).annotation.object(n).name;
        end
    end
end
