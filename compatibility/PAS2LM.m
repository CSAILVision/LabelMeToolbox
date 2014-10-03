function PAS2LM(folderAnnotationPAS, HOMEfolderAnnotationLM, folder)
%
% Translates from PASCAL to LabelMe format.
% It calls functions from the PASCAL toolbox
%
% PAS2LM(folderAnnotationPAS, HOMEfolderAnnotationLM, foldername)
%
% You have to create the folder HOMEfolderAnnotationLM/foldername first

files = dir(fullfile(folderAnnotationPAS, '*.txt'));

Nfiles = length(files);

for i = 1:Nfiles
    filename = files(i).name;
    record=PASreadrecord(fullfile(folderAnnotationPAS,filename));

    clear v xml

    v.filename = strrep(filename, '.txt', '.jpg');
    v.folder = folder;
    v.source.sourceImage = record.database;
    v.source.sourceAnnotation = record.database;
    Nobjects = length(record.objects);
    for o = 1:Nobjects
        v.object(o).name = record.objects(o).label;
        v.object(o).deleted = 0;
        v.object(o).verified = 1;
        %v.object(o).date = filesdate{i};

        x = record.objects(o).bbox;
        X = [x(1) x(3) x(3) x(1)];
        Y = [x(2) x(2) x(4) x(4)];

        Npoints = 4;
        for n = 1:Npoints
            v.object(o).polygon.pt(n).x = X(n);
            v.object(o).polygon.pt(n).y = Y(n);
        end
    end

    xml.annotation = v;
    nameXML = strrep(filename, '.txt', '.xml');
    writeXML(fullfile(HOMEfolderAnnotationLM,folder,nameXML), xml);end
end


