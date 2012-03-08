% This script can be used to create a folder of annotations for an image
% database. Each annotation file is empty.

folderBase = 'C:\atb\test\code\roomDatabase\Images';
folderXML = 'C:\atb\test\code\roomDatabase\Annotations';

folders = dir(folderBase);
folders = {folders.name};
folders = setdiff(folders, {'.', '..'});

for f = 1:length(folders)
    folder = folders{f}
    
    filesImages = dir(fullfile(folderBase, folder, '*.jpg'));
    filesImages = {filesImages(:).name};
    
    mkdir(folderXML, folder)

    for i=1:length(filesImages)
        disp([length(filesImages)-i length(folders)-f])
        
        name = filesImages{i};
        dst = fullfile(folderXML, folder, strrep(name, 'jpg', 'xml'));
        
        clear v xml
        
        v.filename = filesImages{i};
        v.folder = folder;
        %v.source.sourceImage = 'web';
        %v.source.sourceAnnotation = 'web';

        xml.annotation = v;
        nameXML = dst;
        writeXML(nameXML, xml);
    end
end

