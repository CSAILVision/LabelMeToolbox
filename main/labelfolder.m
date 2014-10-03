function labelfolder(HOMEIMAGES, HOMEANNOTATIONS)
% bb = labelimage(img)
%
% It returns bounding boxes. It does not ask for object names. 
% Simple script to label bounding boxes on an image.
%
% Use the online tool for labeling!
% 
% Output:
%   bb = bounding boxes. Each row is [xmin ymin width height]

objectname = 'building';

folders = folderlist(HOMEIMAGES);

%f = 4; n = 218;

for f = 5:length(folders)
    imgfiles = dir(fullfile(HOMEIMAGES, folders{f}, '*.jpg'));
    
    for n = 1:length(imgfiles)
        disp([f n])
        anofile = fullfile(HOMEANNOTATIONS, folders{f}, strrep(imgfiles(n).name, '.jpg', '.xml'));
        
        todo = 1;
        M = 0;
        
        % if annotation already exists, skip image
        if exist(anofile, 'file')
            % read annotation file
            clear v
            v = LMread(anofile);
            
            % check if already annotated
            jc = LMobjectindex(v, objectname);
            if ~isempty(jc)
                todo = 0;
            else
                if isfield(v, 'object')
                    M = length(v.object);
                else
                    M = 0;
                end
            end
        else
            clear v
            v.filename = imgfiles(n).name;
            v.folder = folders{f};
            M = 0;
        end
        
        if todo
            % check if annotation folder exists
            if ~exist(fullfile(HOMEANNOTATIONS, folders{f}), 'dir')
                mkdir(fullfile(HOMEANNOTATIONS, folders{f}))
            end
            
            % label image
            img = imread(fullfile(HOMEIMAGES, folders{f}, imgfiles(n).name));
            bb = labelimage(img, v);
            close
            % bb = bounding boxes. Each row is [xmin ymin width height]
            
            
            % create annotation struct
            for m = 1:size(bb,1)
                b = bb(m,:);
                x = [b(1) b(1)+b(3) b(1)+b(3) b(1)      b(1)];
                y = [b(2) b(2)      b(2)+b(4) b(2)+b(4) b(2)];
                v.object(M+m).name = objectname;
                v.object(M+m).deleted = '0';
                v.object(M+m).polygon = setLMpolygon(x',y');
            end
            
            clear xml
            xml.annotation = v;
            
            
            % save annotation
            writeXML(anofile, xml);
        end
    end
end

