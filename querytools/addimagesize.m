function [D, Nrows, Ncols] = addimagesize(D, HOMEIMAGES)
%
% [D, nrows, ncols] = addimagesize(D, HOMEIMAGES)

n = length(D);
Nrows = zeros(n,1);
Ncols = zeros(n,1);


for i = 1:n
    if mod(i,10)==1; disp(n-i); end
    disp(fullfile(D(i).annotation.folder, D(i).annotation.filename))
    
    if ~isfield(D(i).annotation,'imagesize')
        try
            info = imfinfo(strrep(strrep(fullfile(HOMEIMAGES, D(i).annotation.folder, D(i).annotation.filename), '\', '/'), ' ', '%20'));
            nrows = info.Height;
            ncols = info.Width;
        catch
            [ncols, nrows] = getaproximagesize(D(i).annotation);
        end
        
        D(i).annotation.imagesize.nrows = (nrows);
        D(i).annotation.imagesize.ncols = (ncols);
        
    else
        if ischar(D(i).annotation.imagesize.nrows)
            D(i).annotation.imagesize.nrows = str2num(D(i).annotation.imagesize.nrows);
            D(i).annotation.imagesize.ncols = str2num(D(i).annotation.imagesize.ncols);
        end
    end
    
    Nrows(i) = D(i).annotation.imagesize.nrows;
    Ncols(i) = D(i).annotation.imagesize.ncols;
end


