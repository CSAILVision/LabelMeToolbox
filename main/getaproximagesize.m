function [ncols, nrows] = getaproximagesize(annotation)
%
% THIS IS AN APPROXIMATION
%
% Script that return the image size. First it looks to see if there is a
% field in the annotation that provides the image size. If the field is not
% present, it will return the size estimated using the coordinates of the
% annotated objects. This is faster than reading the image, but it might
% return underestimates of the real image size if not all the objects are
% annotated.

ncols = 0;
nrows = 0;

if isfield(annotation,'imagesize')
    ncols = (annotation.imagesize.ncols);
    nrows = (annotation.imagesize.nrows);
    if ischar(ncols)
        ncols = str2num(ncols);
        nrows = str2num(nrows);
    end
else
    % Estimate image size. This information is not
    % available in the annotation and reading the image is too slow, so
    % we estimate it by looking at the polygons:
    if isfield(annotation,'object')
        Nobj = length(annotation.object);

        for j = 1:Nobj
            [X,Y] = getLMpolygon(annotation.object(j).polygon);
            ncols = max(ncols, max(X));
            nrows = max(nrows, max(Y));
        end
    end
end
