function ADMINrandomfilenames(HOMEANNOTATIONS, HOMEIMAGES, annotationfolder)
%
% ADMINrandomfilenames(HOMEANNOTATIONS, HOMEIMAGES, annotationfolder)
%
% or
%
% ADMINrandomfilenames(HOMEIMAGES)

str = computer;
if ~isempty(findstr(lower(str), 'win'))
    WIN = 1;
else
    WIN = 0;
end

%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));

root = 'sun_e'; % this is the string that will be part of the first characters of the image name.
root = 'labelme_'; % this is the string that will be part of the first characters of the image name.
Nchar = 15;

if nargin == 1
    HOMEIMAGES = HOMEANNOTATIONS;
end

% create list of folders
if nargin == 3
    Folder = {annotationfolder};
else
    Folder = [{''} folderlist(HOMEIMAGES)];
end


for n = 1:length(Folder)
    f = Folder{n};
    
    if ~isempty(fullfile(HOMEIMAGES, f))
        files = dir(fullfile(HOMEIMAGES, f, '*.jpg'));
        files = [files; dir(fullfile(HOMEIMAGES, f, '*.JPG'))];
        files = [files; dir(fullfile(HOMEIMAGES, f, '*.jpeg'))];
        
        Nfiles = length(files);
        for i = 1:Nfiles
            % check if file already starts with the root, then ignore
            
            oldimgname = files(i).name;
            if isempty(strfind(oldimgname, 'sun_'))
                oldanoname = strrep(oldimgname, '.jpg', '.xml');
                oldanoname = strrep(oldanoname, '.JPG', '.xml');
                oldanoname = strrep(oldanoname, '.jpeg', '.xml');
                
                % generate new name
                newname = lower([root char([65+fix(26*rand(1,Nchar))])]);
                newimgname = [newname '.jpg'];
                newanoname = [newname '.xml'];
                
                % rename image
                src = fullfile(HOMEIMAGES, f, oldimgname);
                dest = fullfile(HOMEIMAGES, f, newimgname);
                if WIN
                    cmd = sprintf('rename "%s" %s', src, newimgname);
                else
                    cmd = sprintf('mv "%s" %s', src, dest);
                end
                disp(cmd)
                system(cmd);
                
                % check if annotation exists.
                src = fullfile(HOMEANNOTATIONS, f, oldanoname);
                if exist(src, 'file')
                    % rename file
                    dest = fullfile(HOMEANNOTATIONS, f, newanoname);
                    if exist(dest, 'file')
                        error('Duplicate image detected')
                    end
                    
                    if WIN
                        cmd = sprintf('rename "%s" %s', src, newanoname);
                    else
                        cmd = sprintf('mv "%s" %s', src, dest);
                    end
                    disp(cmd)
                    system(cmd);
                    
                    % load annotation
                    xml = loadxml(dest);
                    
                    % change inside annotation file
                    ii = strfind(xml, '<filename>');
                    jj = strfind(xml, '</filename>');
                    xml = [xml(1:ii+9) newimgname xml(jj:end)];
                    
                    % save annotation
                    fid = fopen(dest,'w');
                    fprintf(fid, xml');
                    fclose(fid);
                end
            end
        end
    end
end


function xml = loadxml(filename)
[fid, message] = fopen(filename,'r');
if fid == -1; error(message); end
xml = fread(fid, 'uint8=>char');
fclose(fid);
xml = xml';




