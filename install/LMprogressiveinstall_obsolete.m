function LMprogressiveinstall(folderlist, HOMEIMAGES, HOMEANNOTATIONS);
%
% Downloads a set of folders from the LabelMe dataset.
%  LMprogressiveinstall(folderlist, HOMEIMAGES, HOMEANNOTATIONS);
%
% This function is useful if you do not want to download the entire
% dataset. You can first browse the dataset, and when you have decided for
% a set of folders that you want to use, you can use this function to
% download only those folders.
%
% Contribute to the dataset by labeling few images:
% http://people.csail.mit.edu/brussell/research/LabelMe/intro.html

Nfolders = length(folderlist);
webpageanno = 'http://people.csail.mit.edu/brussell/research/LabelMe/Annotations'
webpageimg = 'http://people.csail.mit.edu/brussell/research/LabelMe/Images'

% create folders:
disp('create folders');
for i = 1:Nfolders
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(HOMEIMAGES, folderlist{i});
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(HOMEANNOTATIONS, folderlist{i});
end


disp('progressively downloading images ..., # of folders:')
for f = 1:Nfolders
    disp(sprintf('%d/%d, %s', f, Nfolders, folderlist{f}))
    wpi = [webpageimg  '/' folderlist{f}];
    images = urldir(wpi, 'IMG');
    Nimages = length(images);
    for i = 1:Nimages
        % if the image already exist, then overwrite
        fp = fopen(fullfile(HOMEIMAGES,folderlist{f},images(i).name));
        if fp < 0
            [F,STATUS] = urlwrite([wpi '/' images(i).name], fullfile(HOMEIMAGES,folderlist{f},images(i).name));
%            disp(sprintf('downloading: %s', images(i).name))
        else
            fclose(fp); 
%            disp(sprintf('no need to download: %s', images(i).name))
        end
    end
    end

disp('downloading all annotations..., # of folders:')
for f = 1:Nfolders
    disp(sprintf('%d/%d, %s', f, Nfolders, folderlist{f}))
    
    wpa = [webpageanno '/' folderlist{f}];
    annotations = urldir(wpa, 'TXT');
    Nanno= length(annotations);
    for i = 1:Nanno
        [F,STATUS] = urlwrite([wpa '/' annotations(i).name], fullfile(HOMEANNOTATIONS,folderlist{f},annotations(i).name));
    end
end
