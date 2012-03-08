function D = addimagesize(D, HOMEIMAGES)

n = length(D);

for i = 1:n
    if mod(i,10)==1; disp(n-i); end
    
    if ~isfield(D(i).annotation,'imagesize')
      try
        info = imfinfo(strrep(strrep(fullfile(HOMEIMAGES, D(i).annotation.folder, D(i).annotation.filename), '\', '/'), ' ', '%20'));
        nrows = info.Height;
        ncols = info.Width;
        
        D(i).annotation.imagesize.nrows = num2str(nrows);
        D(i).annotation.imagesize.ncols = num2str(ncols);
      catch
        [ncols, nrows] = getaproximagesize(D(i).annotation);
        
        D(i).annotation.imagesize.nrows = num2str(nrows);
        D(i).annotation.imagesize.ncols = num2str(ncols);
      end
    end
end

