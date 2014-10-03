function [relativearea, name] = objectareas(D)


k = 0;
for i = 1:length(D);
    if isfield(D(i).annotation, 'object')
        Nobjects = length(D(i).annotation.object);

        nrows = D(i).annotation.imagesize.nrows;
        ncols = D(i).annotation.imagesize.ncols;
        
        for n = 1:Nobjects
            [X,Y] = getLMpolygon(D(i).annotation.object(n).polygon);

            area = polyarea(X,Y); % ignores intersections
            
            k = k+1;
            relativearea(k) = area/(nrows*ncols);
            name{k} = D(i).annotation.object(n).name;
        end
    end
end
