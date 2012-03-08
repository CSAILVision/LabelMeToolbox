function ADMINremovespaces(HOMEANNOTATIONS, HOMEIMAGES, annotationfolder)
%
% Removes non-alphabetic characters, spaces, %2025 and %20 from filenames and replaces them with '_'
% This function is to be used with caution as it might affect other users.
% 
% Those characteres can be introduced sometimes when reading images from
% the web.
%
% ADMINremovespaces(HOMEANNOTATIONS, HOMEIMAGES, annotationfolder)

% Rename images

% create list of folders

if nargin == 1
    HOMEIMAGES = HOMEANNOTATIONS;
end

if nargin == 3
    Folder = {annotationfolder};
else
    folders = genpath(HOMEIMAGES);
    h = [findstr(folders,  pathsep)];
    h = [0 h];
    Nfolders = length(h)-1;
    for i = 1:Nfolders
        tmp = folders(h(i)+1:h(i+1)-1);
        tmp = strrep(tmp, HOMEIMAGES, ''); tmp = tmp(2:end);
        Folder{i} = tmp;
    end
end

for n = 1:length(Folder)
    annotationfolder = Folder{n};
    
    if ~isempty(HOMEIMAGES)
        files = dir(fullfile(HOMEIMAGES, annotationfolder, '*.jpg'));
        
        Nfiles = length(files);
        for i = 1:Nfiles
            filename = fullfile(HOMEIMAGES, annotationfolder, files(i).name);
            
            % rename image file
            src = filename;
            dest = removecaracters(files(i).name);
            cmd = sprintf('rename "%s" %s', src, dest);
            disp(cmd)
            system(cmd)
        end
    end
    
    % Rename annotations and replace %2025 and %20 and spaces by '_' from annotation.filename
    if ~isempty(HOMEANNOTATIONS)
        files = dir(fullfile(HOMEANNOTATIONS, annotationfolder, '*.xml'));
        
        Nfiles = length(files);
        for i = 1:Nfiles
            filename = fullfile(HOMEANNOTATIONS, annotationfolder, files(i).name);
            
            % rename image file indexed inside the file
            [fid, message] = fopen(filename,'r');
            if fid == -1; error(message); end
            xml = fread(fid, 'uint8=>char');
            fclose(fid);
            xml = xml';
            
            ii = strfind(xml, '<filename>');
            jj = strfind(xml, '</filename>');
            
            if ~isempty(i)
                tmp = removecaracters(xml(ii:jj));
                xml = [xml(1:ii-1) tmp xml(jj+1:end)];
                
                % save annotation
                fid = fopen(filename,'w');
                fprintf(fid, xml');
                fclose(fid);
                
                
                % rename annotation file
                src = filename;
                dest = removecaracters(files(i).name);
                cmd = sprintf('rename "%s" %s', src, dest);
                disp(cmd)
                system(cmd)
            else
                disp(filename)
            end
        end
    end
end


function out = removecaracters(in)
out = lower(in);

out = strrep(out, ' ', '_');
out = strrep(out, '%2520', '_');
out = strrep(out, '%20', '_');

out = regexprep(out, '\W', '_');

            
            

