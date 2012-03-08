function VLMinstall(varargin)
%
% Downloads a set of folders from the LabelMe dataset.
%
% 1) Install all the videos (it can take a long time to complete)
%  LMinstall(HOMEFRAMES, HOMEANNOTATIONS);
%
% 2) install only videos in the specified folder
%  LMinstall(folder, HOMEFRAMES, HOMEANNOTATIONS);
%
% HOMEFRAMES and HOMEANNOTATIONS point to your local destination folders.
%
% This function is useful if you do not want to download the entire
% dataset. You can first browse the dataset, and when you have decided for
% a set of folders that you want to use, you can use this function to
% download only those folders.
%
% Contribute to the dataset by labeling few images:
% http://labelme.csail.mit.edu/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Video LabelMe is a WEB-based image annotation tool and a Matlab toolbox that allows 
% researchers to label images and share the annotations with the rest of the community. 
%    Copyright (C) 2009  MIT, Computer Science and Artificial
%    Intelligence Laboratory. Jenny Yuen, Antonio Torralba, Bryan Russell
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


% If this function stops working, you might need to download the newest
% version of the toolbox in order to update the web addresses:

webpageimg = 'http://labelme.csail.mit.edu/LabelMeVideo/VLMFrames/';
webpageanno = 'http://labelme.csail.mit.edu/LabelMeVideo/VLMAnnotations/';

Narguments = length(varargin);

switch Narguments
    case {0,1}
        error('Not enough input arguments.')
    case 2
        disp('Install full database (more than 10Gb required)')
        HOMEIMAGES = varargin{1};
        HOMEANNOTATIONS = varargin{2};
        
        disp('generating folder list...')
        list_fr = folderlist(webpageimg);
        list_an = folderlist(webpageanno);
     case 3
         list = varargin{1};
         HOMEIMAGES = varargin{2};
         HOMEANNOTATIONS = varargin{3};

         disp('generating folder list...')
         list_fr = folderlist(webpageimg, list);
         list_an = folderlist(webpageanno, list);
         %     case 4
%         folders = varargin{1};
%         filelist = varargin{2};
%         list = unique(folders);
%         HOMEIMAGES = varargin{3};
%         HOMEANNOTATIONS = varargin{4};
end



Nfolders = length(list_fr);

% create folders:
disp('Create folders...');
for i = 1:length(list_fr)
    mkdir(HOMEIMAGES, list_fr{i});
end
for i = 1:length(list_an)
    mkdir(HOMEANNOTATIONS, list_an{i});
end




disp('Download annotations...')
for f = 1:length(list_an)
    disp(sprintf('Downloading folder %s (%d/%d)...',  list_an{f}, f, Nfolders))
    wpa = [webpageanno '/' list_an{f}];
    
    annotations = urldir(wpa, 'txt');
    if ~isempty(annotations)
        annotations = {annotations(:).name};
    end
    
    Nanno = length(annotations);
    for i = 1:Nanno
        disp(sprintf('    Downloading annotation %s (%d/%d)...',  annotations{i}, i, Nanno))
        [F,STATUS] = urlwrite([wpa '/' annotations{i}], fullfile(HOMEANNOTATIONS,list_an{f},annotations{i}));
        if STATUS == 0
            disp(sprintf('annotation file %s does not exist', annotations{i}))
        end
    end
end


disp('Download frames...')
for f = 1:Nfolders
    disp(sprintf('Downloading folder %s (%d/%d)...',  list_fr{f}, f, Nfolders))
    
    wpi = [webpageimg  '/' list_fr{f}];
    
    images = urldir(wpi, 'img');
    if ~isempty(images)
        images = {images(:).name};
    end    
    
    Nimages = length(images);
    for i = 1:Nimages
        disp(sprintf('    Downloading image %s (%d/%d)...',  images{i}, i, Nimages))
        [F,STATUS] = urlwrite([wpi '/' images{i}], fullfile(HOMEIMAGES,list_fr{f},images{i}));
    end
end




