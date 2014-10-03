function D = LMenlargePolygon(D, objectname, percent)
%
% Extends (or decreases) a polygon x by a percentage
%
% D = LMenlargePolygon(D, objectname, percent)
%
% This function will scale the polygons of the selected object class.
%
%   D 
%   object name (it will perform exact matching)
%   percent (1.2 = enlarges the polygon by 20%)

for i = 1:length(D)
    k = LMobjectindex(D(i).annotation, objectname, 'exact');
    if ~isempty(k)
        if isfield(D(i).annotation, 'imagesize')
            nrows = D(i).annotation.imagesize.nrows;
            ncols = D(i).annotation.imagesize.ncols;
        else
            nrows = []; ncols = [];
        end
        for n = 1:length(k)            
            D(i).annotation.object(k(n)).polygon = enlarge(D(i).annotation.object(k(n)).polygon, percent, [nrows ncols]);
            
            % If there are parts, scale all parts
            if isfield(D(i).annotation.object(k(n)),'parts')
                if isfield(D(i).annotation.object(k(n)).parts,'object')
                    for m = 1:length(D(i).annotation.object(k(n)).parts.object)
                        D(i).annotation.object(k(n)).parts.object(m).polygon = ...
                            enlarge(D(i).annotation.object(k(n)).parts.object(m).polygon, percent, [nrows ncols]);
                    end
                end
            end
        end
    end
end



function polygon = enlarge(polygon, percent, imagesize)

[x,y] = getLMpolygon(polygon);

% get bounding box
xmin = min(x);
xmax = max(x);
ymin = min(y);
ymax = max(y);

% enlarge with respect to center of bounding box
cx = (xmax+xmin)/2;
cy = (ymax+ymin)/2;
x = (x-cx)*percent + cx;
y = (y-cy)*percent + cy;

x = round(x);
y = round(y);

if ~isempty(imagesize)
    x = max(1,x);
    y = max(1,y);
    x = min(imagesize(2), x);
    y = min(imagesize(1), y);
end

polygon = setLMpolygon(x,y);