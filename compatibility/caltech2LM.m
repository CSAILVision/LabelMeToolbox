% Transforms the annotation files of Caltech 101 into LabelMe format
% 
% This file might require some modifications.
% As it is today, the 101 caltech folders have still some inconsistencies
% (folders Faces_2, Faces_3 are missmatched with the images).
%

% The script creates the 101 folders at the destination LabelMe path.

% you need the labelme toolbox. 
addpath('/afs/csail.mit.edu/u/t/torralba/public_html/LabelMeToolbox')

% put here the root folder containing the annotation files for the 101
% dataset
folderbase101 = '/afs/csail.mit.edu/u/t/torralba/test/Annotations';

% put here the LabelMe destination folder
folderoutput = '/afs/csail.mit.edu/u/t/torralba/test/AnnotationsXML';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In principle, you do not need to change anything bellow this line
folders = dir(folderbase101);
Nfolders = length(folders);

for f = 1:Nfolders
    w = dir(fullfile(folderbase101, folders(f).name, '*.mat'));

    n = length(w);

    if n>10
        mkdir(fullfile(folderoutput, folders(f).name))

        for i = 1:n
            filename = w(i).name;
            data = load(fullfile(folderbase101, folders(f).name, filename));

            clear v xml

            filename = strrep(filename, 'annotation', 'image');
            
            v.filename = strrep(filename, '.mat', '.jpg');
            v.folder = folders(f).name;
            v.source.sourceImage = 'caltech 101';
            v.source.sourceAnnotation = 'caltech 101';
            Nobjects = 1;
            for o = 1:Nobjects
                v.object(o).name = lower(folders(f).name);
                v.object(o).deleted  = 0;
                v.object(o).verified = 1;

                x = data.obj_contour;
                X = round(x(1,:)+data.box_coord(3));
                Y = round(x(2,:)+data.box_coord(1));

                Npoints = length(X);
                for n = 1:Npoints
                    v.object(o).polygon.pt(n).x = X(n);
                    v.object(o).polygon.pt(n).y = Y(n);
                end
            end

            xml.annotation = v;
            nameXML = strrep(filename, '.mat', '.xml');
            writeXML(fullfile(folderoutput, folders(f).name, nameXML), xml);
        end
    end
end


