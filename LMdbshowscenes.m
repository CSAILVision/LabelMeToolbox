function LMdbshowscenes(D, HOMEIMAGES, subimages, showanno, titles)
%
% Shows all the images in the database with annotation.
% This function can be used in combination with LMquery
%
% LMdbshowscenes(D, HOMEIMAGES, subimages, showanno)

%if nargin == 1
%    error('Not enought input parameters. You need to give the path to the images');
%end

Nimages = length(D);
if nargin > 2
    Nx = subimages(2);
    Ny = subimages(1);
else
    Nx = 6; Ny = 5; % will show 6x5 images per figure
end
Dx = 1/Nx; Dy = 1/Ny; 

if nargin < 4
    showanno = 1;
end

i = 0;
while i<Nimages
    figure
    for y = Ny-1:-1:0
        for x = 0:Nx-1
            i = i+1;
            if i>Nimages
                return
            end
            
            axes('position', [x*Dx y*Dy Dx Dy]); % create axis

            if nargin>1
                img = LMimread(D, i, HOMEIMAGES); % Load image

                if showanno
                    scaling = min(1,320/size(img,1)); % scale factor to create thumbnail
                    [annotation, img] = LMimscale(D(i).annotation, img, scaling, 'nearest'); % scale image

                    annotation = LMsortlayers(annotation, img);

                    [h,class] = LMplot(annotation, img); % show image and polygons
                else
                    imagesc(img)
                    axis('off'); axis('equal'); axis('tight')
                end
            else
                [h,class] = LMplot(D(i).annotation); % show image and polygons
                axis('ij')
            end
            
            if nargin==5
                title(titles{i})
            end
            drawnow
        end
    end
end


