function ADMINvalidimagefilenames(folder)
% 

disp('do not use on labelme image folders')

folders = folderlist(folder);
folders = [{''} folders];

for m = 1:length(folders)
    % Transforms filenames into lowercase
    filesImages = [dir(fullfile(folder, folders{m}, '*.jpg')); dir(fullfile(folder, folders{m}, '*.JPG'))];
    filesImages = {filesImages(:).name};
    filesImages = setdiff(filesImages, {'.', '..','Thumbs.db'});
    
    delete(fullfile(folder, folders{m}, '*.png'))
    delete(fullfile(folder, folders{m}, '*.gif'))
    delete(fullfile(folder, folders{m}, '*.bmp'))
    for i=1:length(filesImages)

        name = filesImages{i}

        dest = strrep(name, '.JPEG', '.jpg');
        dest = strrep(dest, '.JPG', '.jpg');
        dest = strrep(dest, '.jpeg', '.jpg');
        dest = strrep(dest, '.jpg', ''); 
        
        dest = strrep(dest, '�', 'e');
        dest = strrep(dest, '�', 'E');
        dest = strrep(dest, '�', 'a');
        dest = strrep(dest, '�', 'a');
        dest = strrep(dest, '�', 'i');
        dest = strrep(dest, '�', 'I');
        dest = strrep(dest, '�', 'o');
        dest = strrep(dest, '�', 'o');
        dest = strrep(dest, '�', 'O');
        dest = strrep(dest, '�', 'u');
        dest = strrep(dest, '�', 'U');
        dest = strrep(dest, '�', 'u');
        dest = strrep(dest, '�', 'U');
        dest = strrep(dest, '�', 'n');
        dest = strrep(dest, '�', 'N');        
        dest = strrep(dest, '�', 'c');
        
        dest = regexprep(dest, '\W', '_');
        dest = strrep(dest, '+', '_');
        dest = strrep(dest, '-', '_');
        dest = strrep(dest, ' ', '_');
        dest = strrep(dest, '__', '_');
        dest = strrep(dest, '__', '_');
        dest = strrep(dest, '__', '_');

        dest = strrep(dest, '_.', '.');
        dest = [lower(dest) '.jpg'];
        
        if ~strcmp(dest, name)
            if exist(fullfile(folder, folders{m}, dest), 'file')
                dest = strrep(dest, '.jpg', '_b.jpg');
            end
            
            src = fullfile(folder, folders{m}, name);

            cmd = sprintf('rename "%s" %s', src, dest);
            cmd = sprintf('mv "%s" %s', src, dest);

            system(cmd)
        end
        %end
    end
end

