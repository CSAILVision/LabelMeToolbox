function ADMINrandomfilenames_video(HOMEANNOTATIONS, HOMEIMAGES, annotationfolder)
%
% HOMEVIDEOS = '/Users/torralba/atb/Databases/corrected/VideoLabelMe/VLMOrigVideos';
% HOMEVIDEOANNOTATIONS = '/Users/torralba/atb/Databases/corrected/VideoLabelMe/VLMAnnotations';
%
% ADMINrandomfilenames_video(HOMEVIDEOS)
% ADMINrandomfilenames_video(HOMEVIDEOANNOTATIONS, HOMEVIDEOS)
% ADMINrandomfilenames_video(HOMEVIDEOANNOTATIONS, HOMEVIDEOS, annotationfolder)

LINUX = 1;
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));

extension = {'.avi', '.AVI', '.mov', '.MOV'};
root = 'sun_'; % this is the string that will be part of the first characters of the image name.
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
        files = [];
        for m = 1:length(extension)
            files = [files; dir(fullfile(HOMEIMAGES, f, ['*' extension{m}]))];
        end
        files = {files.name};
        files = sort(files);
        
        Nfiles = length(files);
        
        % create new filenames and sort them
        if Nfiles>0
            clear newnames
            for i = 1:Nfiles
                newnames{i} = lower([root f '_' char([65+fix(26*rand(1,Nchar))])]);
            end
            newnames = sort(newnames);
        end
        
        for i = 1:Nfiles
            % check if file already starts with the root, then ignore
            oldimgname = files{i};
            if ~strcmp(oldimgname(1:3),'sun')
                
                oldanoname   = [oldimgname(1:end-4) '.xml']; %strrep(oldimgname, extension, '.xml');
                oldextension = oldimgname(end-3:end);
                
                % generate new name
                newname = newnames{i};
                newflvname = [newname '.flv'];
                newvidname = [newname oldextension];
                newanoname = [newname '.xml'];
                
                % rename image
                src = fullfile(HOMEIMAGES, f, oldimgname);
                dest = fullfile(HOMEIMAGES, f, newvidname);
                if LINUX
                    cmd = sprintf('mv "%s" %s', src, dest);
                    disp(cmd)
                    system(cmd);
                    cmd = sprintf('mv "%s" %s', strrep(src, oldextension, '.THM'), strrep(dest, oldextension, '.THM'));
                    disp(cmd)
                    system(cmd);
                else
                    cmd = sprintf('rename "%s" %s', src, newvidname);
                    disp(cmd)
                    system(cmd);    cmd = sprintf('rename "%s" %s', strrep(src, oldextension, '.THM'), strrep(newvidname, oldextension, '.THM'));
                    disp(cmd)
                    system(cmd);
                end

                % check if annotation exists.
                src = fullfile(HOMEANNOTATIONS, f, oldanoname);
                if exist(src, 'file')
                    % rename file
                    dest = fullfile(HOMEANNOTATIONS, f, newanoname);
                    if exist(dest, 'file')
                        error('Duplicate image detected')
                    end
                    
                    if LINUX
                        cmd = sprintf('mv "%s" %s', src, dest);
                    else
                        cmd = sprintf('rename "%s" %s', src, newanoname);
                    end
                    disp(cmd)
                    system(cmd);
                    
                    % load annotation
                    xml = loadxml(dest);
                    
                    % change inside annotation file
                    ii = strfind(xml, '<filename>');
                    jj = strfind(xml, '</filename>');
                    xml = [xml(1:ii+9) newflvname xml(jj:end)];
                    
                    % save annotation
                    fid = fopen(dest,'w');
                    fprintf(fid, xml');
                    fclose(fid);
                    
                    %pepe
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




