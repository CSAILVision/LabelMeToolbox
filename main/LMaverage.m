function Average = LMaverage(D, objectname, HOMEIMAGES, object_size, average_size)
%
% Average = LMaverage(D, objectname, HOMEIMAGES)


% Parameters:
if nargin<4
    object_size = [256 256]; % scale normalized
end
if nargin<5
    average_size = object_size*4; % scale normalized
end

b = [ceil((average_size(1)- object_size(1))/2) ceil((average_size(2)- object_size(2))/2)];

L = 128;

disp('selecting objects to average')
if isempty(D)
    D = LMdatabase(HOMEIMAGES, HOMEIMAGES);
    for i = 1:length(D(1:10))
        img = LMimread(D, i, HOMEIMAGES);
        disp(i)
        bb = labelimage(img); % [xmin ymin width height]
        if size(bb,1) >0
            for n = 1:size(bb,1)
                min(bb(n,3), bb(n,4))
                
                D(i).annotation.object(n).name = objectname;
                D(i).annotation.object(n).crop = '0';
                
                x = [bb(n,1) bb(n,1)+bb(n,3) bb(n,1)+bb(n,3) bb(n,1)];
                y = [bb(n,2) bb(n,2) bb(n,2)+bb(n,4) bb(n,2)+bb(n,4)];
                
                D(i).annotation.object(n).polygon.x = x;
                D(i).annotation.object(n).polygon.y = y;

            end
        end
        close
    end
end

D = LMquery(D, 'object.name', objectname,'exact');

disp('removing small and cropped objects from the averaging')
D = addsmallobjectlabel(D, object_size(1)/4, object_size(2)/4);
D = LMquery(D, 'object.name', '-smallobject');
D = LMquery(D, 'object.occluded', 'no');

    
% Align all images (scale and translate) and compute averages
Average = zeros([average_size 3], 'single');


[nrows, ncols, cc] = size(Average);
Counts  = zeros([nrows ncols], 'single');

%[x,y] = meshgrid(0:ncols-1, 0:nrows-1);
%x = x - ncols/2;
%y = y - nrows/2;

figure
for n = 1:length(D)
    n
    clear img Tmp
    img = LMimread(D, n, HOMEIMAGES);
    
    %img = single(img);
    %img = img - min(img(:));
    %img = 256*img / max(img(:));
    %img = uint8(253*img / max(img(:))+2);
    
    if size(img,3)>1
        for k = 1:length(D(n).annotation.object);
            [imgCrop, ~, ~, ~, valid] = LMobjectnormalizedcrop(img, D(n).annotation, k, b, object_size(1), object_size(2));


            if valid(1,1) < 0.5 || valid(end,end)<0.5
                valid = 2*single(valid)-1;
                w = hamming(L); w= w/sum(w);
                valid2 = conv2(valid, w, 'same');
                valid2 = conv2(valid2, w', 'same');
                valid = max(0,valid2.*(valid>0));
            end
            
            imgCrop(isnan(imgCrop))=0;
            imgCrop = single(imgCrop);
            imgCrop(:,:,1) = imgCrop(:,:,1).*valid;
            imgCrop(:,:,2) = imgCrop(:,:,2).*valid;
            imgCrop(:,:,3) = imgCrop(:,:,3).*valid;
            
            Counts = Counts + valid;
            Average = Average + imgCrop;
            
            if 1
                Tmp = Average(1:4:end,1:4:end,:) ./ repmat(Counts(1:4:end,1:4:end)+.000000001, [1 1 3]);
                Tmp = Tmp - min(Tmp(:));
                Tmp = Tmp / max(Tmp(:))*256;
                
                imshow(uint8(Tmp))
                title(n)
                drawnow
            end
        end
    end
end

Average = Average ./ repmat(Counts+.00000001, [1 1 3]);
Average = Average - min(Average(:));
Average = Average / max(Average(:))*65535;

%average = average-prctile(average(:), 3);
%average = 255*average/prctile(average(:), 97);

