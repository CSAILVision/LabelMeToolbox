function [relativearea, Nrows, Ncols] = LMlabeledarea(D, objectname)
%
% Returns the percentage of pixels labeled for each image. 
%

n = length(D);
relativearea = zeros(n,1);
Nrows = zeros(n,1);
Ncols = zeros(n,1);

if nargin == 2
    [D, j] = LMquery(D, 'object.name', objectname);
else
    j = 1:n;
end

for i = 1:length(D);
    relativearea(j(i)) = 0; % default value
    
    if isfield(D(i).annotation, 'object')
        Nobjects = length(D(i).annotation.object);

        if Nobjects > 0
            % Get image size
            if isfield(D(i).annotation, 'imagesize')
                ncols = D(i).annotation.imagesize.ncols;
                nrows = D(i).annotation.imagesize.nrows;
                if ischar(ncols)
                    ncols = str2num(ncols);
                    nrows = str2num(nrows);
                end
            else
                ncols = 0; nrows = 0;
                for n = 1:Nobjects
                    %[X,Y] = getLMpolygon(D(i).annotation.object(n).polygon);
                    [X,Y] = LMobjectpolygon(D(i).annotation, n);
                    ncols = max(ncols, max(X{1}));
                    nrows = max(nrows, max(Y{1}));
                end
            end

            % Scaling (goes faster)
            nrows = max(round(nrows/10),1);
            ncols = max(round(ncols/10),1);
            
            % Labeled pixels
            mask = 0;
            for n = 1:Nobjects
                %[X,Y] = getLMpolygon(D(i).annotation.object(n).polygon);
                [X,Y] = LMobjectpolygon(D(i).annotation, n);
                X = min(max(round(X{1}/10),1),ncols);
                Y = min(max(round(Y{1}/10),1),nrows);
                mask = mask + poly2mask(double(X), double(Y), double(nrows), double(ncols));
            end
            area = sum(mask(:)>0);

            % Relative area
            relativearea(j(i)) = area/(nrows*ncols);
            Nrows(j(i)) = nrows*10;
            Ncols(j(i)) = ncols*10;
        end
    end
end
