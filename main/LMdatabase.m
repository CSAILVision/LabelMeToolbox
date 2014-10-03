function [D, XML] = LMdatabase(varargin)
%function [database, XML] = LMdatabase(HOMEANNOTATIONS, folderlist)
%
% This line reads the entire database into a Matlab struct.
%
% Different ways of calling this function
% D = LMdatabase(HOMEANNOTATIONS); % reads only annotated images
% D = LMdatabase(HOMEANNOTATIONS, HOMEIMAGES); % reads all images
% D = LMdatabase(HOMEANNOTATIONS, folderlist);
% D = LMdatabase(HOMEANNOTATIONS, HOMEIMAGES, folderlist);
% D = LMdatabase(HOMEANNOTATIONS, HOMEIMAGES, folderlist, filelist);
%
% Reads all the annotations.
% It creates a struct 'almost' equivalent to what you would get if you concatenate
% first all the xml files, then you add at the beggining the tag <D> and at the end </D> 
% and then use loadXML.m
%
% You do not need to download the database. The functions that read the
% images and the annotation files can be refered to the online tool. For
% instance, you can run the next command:
%
% HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations'
% D = LMdatabase(HOMEANNOTATIONS);
%
% or 
%
% D = LMdatabase
%
% This will create the database struct without needing to download the
% database. It might be slower than having a local copy. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LabelMe, the open annotation tool
% Contribute to the database by labeling objects using the annotation tool.
% http://labelme.csail.mit.edu/
% 
% CSAIL, MIT
% 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LabelMe is a WEB-based image annotation tool and a Matlab toolbox that allows 
% researchers to label images and share the annotations with the rest of the community. 
%    Copyright (C) 2007  MIT, Computer Science and Artificial
%    Intelligence Laboratory. Antonio Torralba, Bryan Russell, William T. Freeman
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function removes all the deleted polygons. If you want to read them
% too, you have to comment line (at the end): D = LMvalidobjects(D);.

% written by Antonio Torralba

Folder = [];

% Parse input arguments and read list of folders
Narg = nargin;
if Narg==0
    HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations';
else
    HOMEANNOTATIONS = varargin{1};
end
if Narg==3
    HOMEIMAGES = varargin{2};
else
    HOMEIMAGES = '';
end

if Narg>1 && iscell(varargin{Narg})
    switch Narg
        case 2
            Folder = varargin{2};
        case 3
            Folder = varargin{3};
        case 4
            Folder = varargin{3};
            Images = varargin{4};
    end
    Nfolders = length(Folder);
else
    if Narg==2
        HOMEIMAGES = varargin{2};
        if ~strcmp(HOMEIMAGES(1:5), 'http:');
            Folder = folderlist(HOMEIMAGES);
        else
            files = urldir(HOMEIMAGES);
            Folder = {files(2:end).name}; % the first item is the main path name
        end
    else
        if ~strcmp(HOMEANNOTATIONS(1:5), 'http:');
            Folder = folderlist(HOMEANNOTATIONS);
        else
            files = urldir(HOMEANNOTATIONS);
            Folder = {files(2:end).name}; % the first item is the main path name
        end
    end
    Nfolders = length(Folder);
end

%keyboard

% Open figure that visualizes the file and folder counter
Hfig = plotbar;

% Loop on folders
D = []; n = 0; nPolygons = 0;
if nargout == 2; XML = ['<database>']; end
for f = 1:Nfolders
    folder = Folder{f};
    disp(sprintf('%d/%d, %s', f, Nfolders, folder))
    
    
    if Narg<4
        filesImages = [];
        if ~strcmp(HOMEANNOTATIONS(1:5), 'http:');
            filesAnnotations = dir(fullfile(HOMEANNOTATIONS, folder, '*.xml'));
            if ~isempty(HOMEIMAGES)
                filesImages = dir(fullfile(HOMEIMAGES, folder, '*.jpg'));
            end
        else
            filesAnnotations = urlxmldir(fullfile(HOMEANNOTATIONS, folder));
            if ~isempty(HOMEIMAGES)
                filesImages = urldir(fullfile(HOMEIMAGES, folder), 'img');
            end
        end
    else
        filesAnnotations(1).name = strrep(Images{f}, '.jpg', '.xml');
        filesAnnotations(1).bytes = 1;
        filesImages(1).name =  strrep(Images{f}, '.xml', '.jpg');
    end

    if ~isempty(HOMEIMAGES)
        N = length(filesImages);
    else
        N = length(filesAnnotations);
    end
    
    %fprintf(1, '%d ', N)
    emptyAnnotationFiles = 0;
    labeledImages = 0;
    for i = 1:N
        clear v

        if ~isempty(HOMEIMAGES)
            filename = fullfile(HOMEIMAGES, folder, filesImages(i).name);
            filenameanno = strrep(filesImages(i).name, '.jpg', '.xml');
            if ~isempty(filesAnnotations)
                J = strmatch(filenameanno, {filesAnnotations(:).name});
            else
                J = [];
            end
            if length(J)==1
                if filesAnnotations(J).bytes > 0
                    [v, xml] = loadXML(fullfile(HOMEANNOTATIONS, folder, filenameanno));
                    labeledImages = labeledImages+1;
                else
                    %disp(sprintf('file %s is empty', filenameanno))
                    emptyAnnotationFiles = emptyAnnotationFiles+1;
                    v.annotation.folder = folder;
                    v.annotation.filename = filesImages(i).name;
                end
            else
                %disp(sprintf('image %s has no annotation', filename))
                v.annotation.folder = folder;
                v.annotation.filename = filesImages(i).name;
            end
        else
            filename = fullfile(HOMEANNOTATIONS, folder, filesAnnotations(i).name);
            if filesAnnotations(i).bytes > 0
                [v, xml] = loadXML(filename);
                labeledImages = labeledImages+1;
            else
                disp(sprintf('file %s is empty', filename))
                v.annotation.folder = folder;
                v.annotation.filename = strrep(filesAnnotations(i).name, '.xml', '.jpg');
            end
        end
        
        n = n+1;
        
        % Convert %20 to spaces from file names and folder names
        if isfield(v.annotation, 'folder')
            v.annotation.folder = strrep(v.annotation.folder, '%20', ' ');
            v.annotation.filename = strrep(v.annotation.filename, '%20', ' ');
            
            % Add folder and file name to the scene description
            if ~isfield(v.annotation, 'scenedescription')
                v.annotation.scenedescription = [v.annotation.folder ' ' v.annotation.filename];
            end
        end

        
%         if isfield(v.annotation.source, 'type')
%             switch v.annotation.source.type
%                 case 'video' 
%                     videomode = 1;
%                 otherwise 
%                     videomode = 0;
%             end
%         else
%             videomode = 0;
%         end
        
        % Add object ids
        if isfield(v.annotation, 'object')
            %keyboard
            Nobjects = length(v.annotation.object);
            [x,y,foo,t,key] = LMobjectpolygon(v.annotation);
            

            % remove some fields
            if isfield(v.annotation.object, 'verified')
                v.annotation.object = rmfield(v.annotation.object, 'verified');
            end
            
            for m = 1:Nobjects
                % lower case object name
                if isfield(v.annotation.object(m), 'name') 
                    if ~isempty(v.annotation.object(m).name)
                        v.annotation.object(m).name = strtrim(lower(v.annotation.object(m).name));
                    else
                        v.annotation.object(m).name = ' '; % empty names can be a problem later, so lets put a space
                    end
                end
                
                % add id
                if isfield(v.annotation.object(m), 'polygon') && isfield(v.annotation.object(m).polygon, 'pt')
                    if isfield(v.annotation.object(m), 'id')
                        v.annotation.object(m).id = str2num(v.annotation.object(m).id);
                    %else
                        %v.annotation.object(m).id = m;
                    end
                    
                    % Compact polygons
                    v.annotation.object(m).polygon = rmfield(v.annotation.object(m).polygon, 'pt');
                    
                    pol.x = single(x{m});
                    pol.y = single(y{m});
                    pol.t = uint16(t{m});
                    pol.key = uint8(key{m});
                    if isfield(v.annotation.object(m).polygon, 'username')
                        pol.username = v.annotation.object(m).polygon.username;
                    end
                    v.annotation.object(m).polygon = pol;
                elseif isfield(v.annotation.object(m), 'bndbox') || isfield(v.annotation.object(m), 'segm')
                    % if pascal format, then read bounding box and transform it
                    % into polygon.
                    v.annotation.object(m).id = m;
                    pol.x = single(x{m});
                    pol.y = single(y{m});
                    pol.t = uint16(t{m});
                    pol.key = uint8(key{m});
                    v.annotation.object(m).polygon = pol;
                else
                    v.annotation.object(m).deleted = '1';
                end
            end
        end
        
        % Parse estabilization matrix (only used by video labelme):
        %       A= [a b c; d e f; 0 0 1];
        
        if isfield(v.annotation, 'stabilization')
            Nframes = length(v.annotation.stabilization.fr);
            A = zeros([3,3,Nframes]);
            A(3,3,:)=1;
            for k = 1:Nframes
                A(1,1,k) = str2num(v.annotation.stabilization.fr(k).a);
                A(1,2,k) = str2num(v.annotation.stabilization.fr(k).b);
                A(1,3,k) = str2num(v.annotation.stabilization.fr(k).c);
                A(2,1,k) = str2num(v.annotation.stabilization.fr(k).d);
                A(2,2,k) = str2num(v.annotation.stabilization.fr(k).e);
                A(2,3,k) = str2num(v.annotation.stabilization.fr(k).f);
            end
            v.annotation.stabilization = rmfield(v.annotation.stabilization, 'fr');
            v.annotation.stabilization.A = A;
        end
        
        % Translate tracks into arrays
        if isfield(v.annotation, 'tracks')
            Nframes = length(v.annotation.tracks.track);
            for k = 1:Nframes
                v.annotation.tracks.track(k).x = str2num(v.annotation.tracks.track(k).x);
                v.annotation.tracks.track(k).y = str2num(v.annotation.tracks.track(k).y);
                v.annotation.tracks.track(k).v = str2num(v.annotation.tracks.track(k).v);
                v.annotation.tracks.track(k).duration = str2num(v.annotation.tracks.track(k).duration);
            end
        end
        
        % Deal with parts
        %v.annotation = dealparts(v.annotation);
        
        % Change folder name by actual folder.
        % v.annotation.folder = folder; !! This could generate backwards
        % compatibilty issues...
        
        % store annotation into the database
        D(n).annotation = v.annotation;
        
        if nargout == 2
            XML = [XML xml];
        end

        if mod(i,10)==1 && Narg<4
            plotbar(Hfig,f,Nfolders,i,N);
        end
    end
    disp(sprintf(' Total images:%d, annotation files:%d (with %d empty xml files)', N, labeledImages, emptyAnnotationFiles))
end

if nargout == 2; XML = [XML '</database>']; end


% Remove all the deleted objects. Comment this line if you want to see all
% the deleted files.
D = LMvalidobjects(D);

% Add view point into the object name
D = addviewpoint(D);

% Add crop label: 
%words = {'crop', 'occluded', 'part'};
%D = addcroplabel(D, words); % adds field <crop>1</crop> for cropped objects


% Add image size field
% D = addimagesize(D);

% % Summary database;
%[names, counts] = LMobjectnames(D);
%disp('-----------------')
%disp(sprintf('LabelMe Database summary:\n Total of %d annotated images. \n There are %d polygons assigned to %d different object names', length(D), sum(counts), length(names)))
disp(sprintf('LabelMe Database summary:\n Total of %d annotated images.', length(D)))
%disp('-----------------')
% 
close(Hfig)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = plotbar(fig,nf,Nf,ni,Ni)

if nargin > 0
    clf(fig)
    ha = subplot(2,1,1, 'parent', fig); cla(ha)
    p = patch([0 1 1 0],[0 0 1 1],'w','EraseMode','none', 'parent', ha);
    p = patch([0 1 1 0]*nf/Nf,[0 0 1 1],'g','EdgeColor','k','EraseMode','none', 'parent', ha);
    axis(ha,'off')
    title(sprintf('folders (%d/%d)',nf,Nf), 'parent', ha)
    ha = subplot(2,1,2, 'parent', fig); cla(ha)
    p = patch([0 1 1 0],[0 0 1 1],'w','EraseMode','none', 'parent', ha);
    p = patch([0 1 1 0]*ni/Ni,[0 0 1 1],'r','EdgeColor','k','EraseMode','none', 'parent', ha);
    axis(ha,'off')
    title(sprintf('files (%d/%d)',ni,Ni), 'parent', ha)
    drawnow
else
    % Create counter figure
    screenSize = get(0,'ScreenSize');
    pointsPerPixel = 72/get(0,'ScreenPixelsPerInch');
    width = 360 * pointsPerPixel;
    height = 2*75 * pointsPerPixel;
    pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
    fig = figure('Units', 'points', ...
        'NumberTitle','off', ...
        'IntegerHandle','off', ...
        'MenuBar', 'none', ...
        'Visible','on',...
        'position', pos,...
        'BackingStore','off',...
        'DoubleBuffer','on');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function files = urlxmldir(page)

files = []; Folder = [];
page = strrep(page, '\', '/');

%page
disp(sprintf('urlxmldir %s', page))

status=0;
while status == 0
    [folders,status] = urlread(page, 'Timeout', 10);
    if status == 0
        disp(sprintf('Warning: Failure urlxmldir %s. Trying again...',page))
        drawnow
    end
end



if status
    folders = folders(1:length(folders));
    j1 = findstr(lower(folders), '<a href="');
    j2 = findstr(lower(folders), '</a>');
    Nfolders = length(j1);
    
    fn = 0;
    for f = 1:Nfolders
        tmp = folders(j1(f)+9:j2(f)-1);
        fin = findstr(tmp, '"');
        if length(findstr(tmp(1:fin(end)-1), 'xml'))>0
            fn = fn+1;
            Folder{fn} = tmp(1:fin(end)-1);
        end
    end
    
    for f = 1:length(Folder)
        files(f).name = Folder{f};
        files(f).bytes = 1;
    end
end
disp(sprintf('%d files found', length(files)))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dealing with parts
function annotation = dealparts(annotation)

if isfield(annotation, 'object') && isfield(annotation.object(1), 'parts')
    Nobjects = length(annotation.object);
    
    ids = [annotation.object.id];
    
    for n = 1:Nobjects
        parts = annotation.object(n).parts;
        if isfield(parts, 'ispartof')
            [foo, ispartof] = ismember(str2num(annotation.object(n).parts.ispartof), ids);
            annotation.object(n).parts.ispartof = ispartof;
        end
        
        if isfield(parts, 'hasparts')
            [foo, hasparts] = ismember(str2num(annotation.object(n).parts.hasparts), ids);
            annotation.object(n).parts.hasparts = hasparts;
        end
    end

end

