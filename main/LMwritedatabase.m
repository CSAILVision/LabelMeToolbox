function LMwritedatabase(D, HOMEIMAGES, DESTIMAGES, DESTANNOTATIONS)
%
% LMwritedatabase(D, HOMEIMAGES, DESTIMAGES, DESTANNOTATIONS)
% or
% LMwritedatabase(D, DESTANNOTATIONS)
%
% Input:
%   D - Labelme struct
%   HOMEIMAGES - home path with the original images
%   DESTIMAGES - destination folder for the images (leave empty if you do
%                not want to make a copy of the images)
%   DESTANNOTATIONS - destination folder for the annotations

Nfiles = length(D);
for i = 1:Nfiles
    folders{i} = D(i).annotation.folder;
end
folders = unique(folders);
Nfolders = length(folders);

if nargin == 4
    % LMwritedatabase(D, HOMEIMAGES, DESTIMAGES, DESTANNOTATIONS)
    for i = 1:Nfolders
        mkdir(DESTIMAGES, folders{i});
        mkdir(DESTANNOTATIONS, folders{i});
    end

    disp('Writing images')
    for n = 1:Nfiles
        filename = D(n).annotation.filename;
        filename_annotation =  strrep(filename,'.jpg','.xml');

        % copy image
        if length(DESTIMAGES)>0
            img = LMimread(D, n, HOMEIMAGES); % Load image
            imwrite(img, fullfile(DESTIMAGES, D(n).annotation.folder, filename), 'jpg', 'quality', 100);
        end

        % write annotation file
        writeXML(fullfile(DESTANNOTATIONS, D(n).annotation.folder, filename_annotation), D(n));
    end
else
    % LMwritedatabase(D, DESTANNOTATIONS)
    DESTANNOTATIONS = HOMEIMAGES;
    for i = 1:Nfolders
        mkdir(DESTANNOTATIONS, folders{i});
    end
    
    disp('Writing annotations')
    for n = 1:Nfiles
        filename = D(n).annotation.filename;
        filename_annotation =  strrep(filename,'.jpg','.xml');

        % write annotation file
        writeXML(fullfile(DESTANNOTATIONS, D(n).annotation.folder, filename_annotation), D(n));
    end
end

