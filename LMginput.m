function j = LMginput(annotation, x, y)
%
% given an annotation and pixel coordinates (x,y), it returns the indices
% to the polygons that contain that pixel

j = [];
if isfield(annotation, 'object')
    Nobjects = length(annotation.object);
    
    for n = 1:Nobjects
        [X,Y] = getLMpolygon(annotation.object(n).polygon);
        in = inpolygon(x, y, X, Y);
        if in
            j = [j n];
        end
    end
end
