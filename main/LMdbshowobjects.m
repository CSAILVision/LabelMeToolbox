function LMdbshowobjects(database, HOMEIMAGES, subimages)
%
% Shows object thumbnails for all the images in the database.
% This function can be used in combination with LMquery in order to show
% object crops of a single class. 
%
% If you click in the thumnbail it will show a web address that you can use
% to modify the labeling of that object instance.
%
% LMdbshowobjects(database, HOMEIMAGES)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LabelMe, the open annotation tool
% Contribute to the database by labeling objects using the annotation tool.
% http://people.csail.mit.edu/brussell/research/LabelMe/intro.html
% 
% CSAIL, MIT
% 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
    HOMEIMAGES = 'C:\atb\Databases\CSAILobjectsAndScenes\Images'; % you can set here your default folder
end
webpage = 'http://people.csail.mit.edu/brussell/research/LabelMe?collection=LabelMe';

Nimages = length(database);
if nargin == 3
    Nx = subimages(2);
    Ny = subimages(1);
else
    Nx = 10; Ny = 8; % will show 10x8 images per figure
end
Dx = 1/Nx; Dy = 1/Ny; 

figure
x = 0; y = 0;
for i = 1:Nimages
    if isfield(database(i).annotation, 'object')
        Nobjects = length(database(i).annotation.object); n=0;
        try
            img = LMimread(database, i, HOMEIMAGES); % Load image
            [nrows ncols c] = size(img);
            for j = 1:Nobjects
                n = n+1;
                [X,Y] = getLMpolygon(database(i).annotation.object(j).polygon);
                
                crop(1) = max(min(X)-2,1);
                crop(2) = min(max(X)+2,ncols);
                crop(3) = max(min(Y)-2,1);
                crop(4) = min(max(Y)+2,nrows);
                crop = round(crop);
                
                % Image crop:
                %[annotation, Img] = LMimcrop(database(i).annotation, img, crop);
                imgCrop = img(crop(3):crop(4), crop(1):crop(2), :);

                webpageth = sprintf('%s&folder=%s&image=%s',webpage, database(i).annotation.folder, database(i).annotation.filename);
                
                h = axes('position', [x*Dx (Ny-y-1)*Dy Dx Dy]); % create axis
                
                h=image(imgCrop); axis('off'); axis('equal'); hold on
                set(h, 'ButtonDownFcn', ['disp(''' webpageth ''')'])
                h = plot([X; X(1)]-crop(1)+1, [Y; Y(1)]-crop(3)+1, 'r', 'linewidth', 2);
                set(h, 'ButtonDownFcn', ['disp(''' webpageth ''')'])
                % hold on
                
                %h = LMplot(annotation, img);
                drawnow

                x = x+1;
                if x>Nx-1 && i<Nimages
                    x = 0; y = y+1;
                    if y>Ny-1
                        y = 0;
                        figure
                    end
                end
            end
        catch
            disp(sprintf('warning: some problem with image %s/%s',database(i).annotation.folder,database(i).annotation.filename))
        end
    end
end

