function D = deleteObjectsOutsideFrame(D, HOMEIMAGES)
%
% mark as deleted objects with a center of mass outside the image
%


for j = 1:length(D)
    %info = imfinfo(strrep(strrep(fullfile(HOMEIMAGES, D(j).annotation.folder, D(j).annotation.filename), '\', '/'), ' ', '%20'));
    info = imfinfo(strrep(fullfile(HOMEIMAGES, D(j).annotation.folder, D(j).annotation.filename), '\', '/'));
    nrows = info.Height;
    ncols = info.Width;
    
    % Change the size of the polygon coordinates
    if isfield(D(j).annotation, 'object')
        Nobjects = length(D(j).annotation.object); 
        for i = 1:Nobjects
            [x,y] = getLMpolygon(D(j).annotation.object(i).polygon);
            
            xm = mean(x);
            ym = mean(y);
            
            if xm<1 || ym<1 || xm>ncols || ym>nrows
                D(j).annotation.object(i).deleted = '1';
            end
        end
    end
end


