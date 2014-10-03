function ADMINrenamefilenames(HOMEANNOTATIONS, Folder)
%
% Writes in the filename field of the xml file the nane of the filename.
%
% This script is useful when changing image and annotation file names. This function guaratees consistency.


% Create list of folders
if nargin == 1
    Folder = folderlist(HOMEANNOTATIONS);
    Folder = [{''} Folder];
end



Nfolders = length(Folder);

for n = 1:Nfolders
    f = Folder{n};
    
    if ~isempty(fullfile(HOMEANNOTATIONS, f))
        files = dir(fullfile(HOMEANNOTATIONS, f, '*.xml'));
        
        Nfiles = length(files);
        for i = 1:Nfiles
            newname = files(i).name;
            newname = strrep(newname, '.xml', '.jpg');
            
            % load annotation
            dest = fullfile(HOMEANNOTATIONS, f, files(i).name);
            xml = loadxml(dest);
            
            % change inside annotation file
            ii = strfind(xml, '<filename>');
            jj = strfind(xml, '</filename>');
            oldname = strtrim(xml(ii+10:jj-1));
            
            if ~strcmp(oldname, newname)
                disp('rename filename field inside xml')
                
                xml = [xml(1:ii+9) newname xml(jj:end)];
                
                % save annotation
                fid = fopen(dest, 'w');
                fprintf(fid, xml');
                fclose(fid);
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

 