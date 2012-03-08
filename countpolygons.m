function [n,P,ji,jo] = countpolygons(D)
% returns the number of polygons in the database struct
%    n = countpolygons(D)
%
% It also returns the number of control points for each polygon and the
% image and object indices
%    [n,P,ji,jo] = countpolygons(D)
%
%   n = number of polygons in each image
%   P = number of control points in each polygon
%       Example: polygon 34 has P(34) control points and it belong to image
%       number ji(34) and it is polygon number jo(34) within that image

M = length(D);
n = 0;
P = zeros(1,M*10); ndx = 0;
for m = 1:M
    if isfield(D(m).annotation, 'object')
        npol = length(D(m).annotation.object);
        n = n + npol;
        if nargout>1
            for k = 1:npol
                ndx = ndx+1;
                [x,y] = getLMpolygon(D(m).annotation.object(k).polygon);
                P(ndx) = length(x);
                ji(ndx) = m;
                jo(ndx) = k;
            end
        end
    end
end

if nargout>1
    P = P(1:ndx);
    ji = ji(1:ndx);
    jo = jo(1:ndx);
end
