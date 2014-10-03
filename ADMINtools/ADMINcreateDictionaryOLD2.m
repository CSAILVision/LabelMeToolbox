function ADMINcreateDictionary(D, HOMEIMAGES)
% VISUAL OBJECT DICTIONARY
%
% Creates a visual index of all the objects in the database
%
% ADMINcreateDictionary(D, HOMEIMAGES)


homethumbnails = 'objectDictionary';
thSize = 64;
thSize = 48;
minNumInstances = 0;

% List of objects
[names, counts, imagendx, objectndx, descriptionndx] = LMobjectnames(D);

% remove unfrequent objects
if minNumInstances>0
    j = find(counts>=minNumInstances);
    names  = names(j);
    counts = counts(j);
    jj = find(ismember(descriptionndx, j));
    imagendx  = imagendx(jj);
    objectndx = objectndx(jj);
    descriptionndx = descriptionndx(jj);
    [foo,descriptionndx] = ismember(descriptionndx, unique(descriptionndx));
end

% sort objects
[foo, ndx] = sort(counts, 'descend');
%[foo, ndx] = sort(names);
Nnames = length(names);
Ninstances = sum(counts);%length(imagendx);

% Create index with global names and with local instances
fid = fopen('dictionary.js', 'w');
fprintf(fid, 'var d=new Array();\n')
fprintf(fid, 'var n=new Array();\n')
%fprintf(fid, 'var x=new Array();\n')
%fprintf(fid, 'var a=new Array();\n')
%fprintf(fid, 'var p=new Array();\n')
%fprintf(fid, 'var q=new Array();\n')
fprintf(fid, 'var Nnames=%d;\n', Nnames)
fprintf(fid, 'var Ninstances=%d;\n', Ninstances)
fprintf(fid, 'var nrows=%d;\n', Nnames)
fprintf(fid, 'var ncols=%d;\n', 1)

C = 0;
for i = 1:Nnames
    na = strrep(names{ndx(i)}, '''', '');
    if length(na)>1
        na = [upper(na(1)) lower(na(2:end))];
        fprintf(fid, 'd[%d]=''%s'';\n', i, na);          % strings, object names
        fprintf(fid, 'n[%d]=''%d'';\n', i, counts(ndx(i)));         % number of instances
        %fprintf(fid, 'x[%d]=''%d'';\n', i, ndx(i)); % instance index
        %fprintf(fid, 'a[%d]=%d;\n', i, C); % instance index
        C = C+counts(ndx(i));
    else
        disp('short name:')
        disp(na)
    end
end

% m=0;
% for i = 1:Nnames
%     k = find(descriptionndx==ndx(i));
%     for j= 1:length(k)
%         m = m+1;
%         o = objectndx(k(j));
%         im = imagendx(k(j));
%         %page = [D(im).annotation.folder '&image=' D(im).annotation.filename];
%         %page = strrep(page, '.jpg', '');
%         fprintf(fid, 'p[%d]="%s";\n', m, D(im).annotation.folder);  % strings, object names
%         fprintf(fid, 'q[%d]="%s";\n', m, strrep(D(im).annotation.filename, '.jpg', ''));  % strings, object names
%     end
% end

fclose(fid)



% Loop on D, loop on object
instancesCounts = zeros(Nnames,1);
problems = {''};
for i = 1:length(D)
    disp(i)
    k = find(imagendx==i);
    
    if ~isempty(k)
        o = objectndx(k);
        d = descriptionndx(k);
        
        % get thumbnail and extract object and mask
        try
            [annotation, img] = LMread(D, i, HOMEIMAGES);
            for n = 1:length(o)
                %[imgCrop, scaling] = LMobjectnormalizedcrop(img, annotation, o(n), 2, 64, 64);
                imgCrop = LMobjectcrop(img, annotation, o(n), 3);
                %T = imresize(imgCrop, thSize/max(size(imgCrop)), 'bilinear');
                %[foo, T] = LMimpad('', T, [thSize thSize]+6, 255);
                T = imresize(imgCrop, thSize/size(imgCrop,1), 'bilinear');
                %[foo, T] = LMimpad('', T, [size(T,1) size(T,2)]+4, 255);
                
                %thumb = LMobjectThumbnail(D(i).annotation, img, o(n), [64 64]);
                
                
                %T = thumb(:,1:end/2-1,:);
                instancesCounts(d(n)) = instancesCounts(d(n))+1;
                
                %folder = fullfile(homethumbnails, sprintf('obj_%d', d(n)));
                na = strrep(names{d(n)}, '''', '');
                if length(na)>1
                    na = [upper(na(1)) lower(na(2:end))];
                    folder = fullfile(homethumbnails, strrep(na, ' ', '_'));
                    
                    filename = fullfile(folder, sprintf('ins_%d.jpg', instancesCounts(d(n))));
                    
                    mkdir(folder)
                    filename
                    imwrite(T, filename, 'jpg', 'quality', 90)
                    
                    imshow(T)
                    size(T)
                    drawnow
                    
                    % Add to description file: folder, SUN name
                    fid = fopen(fullfile(folder, 'description.txt'), 'a');
                    fprintf(fid, '%s/%s \n', D(i).annotation.folder, D(i).annotation.filename)
                    fclose(fid)
                end
            end
        catch
            a = lasterror
            problems = [problems; a.message];
        end
    end
end


% Loop on folders and sort object instances by prototypicality. We can
% estimate prototypicality by training a classifier and sorting the samples
% using the classification score.



