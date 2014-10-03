function annotation = LMobjectsinsideimage(data, img, boundary, minsize)
% this function removes from the annotation struct any object which polygon
% is outside the boundary of the image. Objects might fall outside the
% image as a result of an image crop. 
%
% Two uses:
% database = LMobjectsinsideimage(database, HOMEIMAGES);
%
% newannotation = LMobjectsinsideimage(database(ndx).annotation, img);
%
% It also removes objects that are too small.
% annotation = LMobjectsinsideimage(annotation, img, boundary, minsize)

if nargin < 3
    boundary = 0; 
end
if nargin < 4
    minsize = 0;
end

if isfield(data, 'annotation')
    % If the input is the database struct
    HOMEIMAGES = img;
    N = length(data);
    for n = 1:N
        info = imfinfo(fullfile(HOMEIMAGES, data(n).annotation.folder, data(n).annotation.filename));
        nrows = info.Height;
        ncols = info.Width;

        % Change the size of the polygon coordinates
        if isfield(data(n).annotation, 'object')
            Nobjects = length(data(n).annotation.object); 
            valid = [];
            for i = 1:Nobjects
                [x,y] = getLMpolygon(data(n).annotation.object(i).polygon);
                Npoints = length(x);
                size_obj = max(max(x)-min(x), max(y)-min(y));
                inside = rectint([boundary boundary ncols-boundary nrows-boundary], [min(x) min(y) max(x)-min(x) max(y)-min(y)]) / (max(x)-min(x)) / (max(y)-min(y)); 
                %if max(x)<=boundary | max(y)<=boundary | min(x)>=ncols | min(y)>=nrows | size_obj < minsize
                if inside <.8  | size_obj < minsize
                    data(n).annotation.object(i).deleted = '1';
                else
                    valid = [valid i];
                end
            end
            data(n).annotation.object = data(n).annotation.object(valid);
        end
    end
    annotation = data;
else
    % If the input is just one annotation:
    annotation = data;

    % Image crop:
    [nrows ncols c] = size(img);

    % Change the size of the polygon coordinates
    if isfield(annotation, 'object')
        Nobjects = length(annotation.object); 
        valid = [];
        for i = 1:Nobjects
            [x,y] = getLMpolygon(annotation.object(i).polygon);
            Npoints = length(x);
            size_obj = max(max(x)-min(x), max(y)-min(y));
            if max(x)<=boundary | max(y)<=boundary | min(x)>=ncols | min(y)>=nrows | size_obj < minsize
                annotation.object(i).deleted = '1';
            else
                valid = [valid i];
            end
        end
        annotation.object = annotation.object(valid);
    end
end

