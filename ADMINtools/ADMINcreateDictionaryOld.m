function ADMINcreateDictionary(D, HOMEIMAGES)
% VISUAL OBJECT DICTIONARY
%
% Creates a visual index of all the objects in the database
%
% ADMINcreateDictionary(D, HOMEIMAGES)


homethumbnails = 'objectDictionary';
thSize = 122;

% List of objects
[names, counts, imagendx, objectndx, descriptionndx] = LMobjectnames(D);
[foo, ndx] = sort(counts, 'descend');
[foo, ndx] = sort(names);
Nnames = length(names);
Ninstances = length(imagendx);

% Create index with global names and with local instances
fid = fopen('dictionary.js', 'w');
fprintf(fid, 'var d=new Array();\n')
fprintf(fid, 'var n=new Array();\n')
fprintf(fid, 'var x=new Array();\n')
fprintf(fid, 'var a=new Array();\n')
fprintf(fid, 'var p=new Array();\n')
fprintf(fid, 'var q=new Array();\n')
fprintf(fid, 'var Nnames=%d;\n', Nnames)
fprintf(fid, 'var Ninstances=%d;\n', Ninstances)
fprintf(fid, 'var nrows=%d;\n', Nnames)
fprintf(fid, 'var ncols=%d;\n', 1)
C = 0;
for i = 1:Nnames
    na = strrep(names{ndx(i)}, '''', '');
    fprintf(fid, 'd[%d]=''%s'';\n', i, na);          % strings, object names
    fprintf(fid, 'n[%d]=''%d'';\n', i, counts(ndx(i)));         % number of instances
    fprintf(fid, 'x[%d]=''%d'';\n', i, ndx(i)); % instance index
    fprintf(fid, 'a[%d]=%d;\n', i, C); % instance index
    C = C+counts(ndx(i));
end
m=0;
for i = 1:Nnames
    k = find(descriptionndx==ndx(i));
    for j= 1:length(k)
        m = m+1;
        o = objectndx(k(j));
        im = imagendx(k(j));
        %page = [D(im).annotation.folder '&image=' D(im).annotation.filename];
        %page = strrep(page, '.jpg', '');       
        fprintf(fid, 'p[%d]="%s";\n', m, D(im).annotation.folder);  % strings, object names
        fprintf(fid, 'q[%d]="%s";\n', m, strrep(D(im).annotation.filename, '.jpg', ''));  % strings, object names
    end
end
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
                T = imresize(imgCrop, thSize/max(size(imgCrop)), 'bilinear');
                [foo, T] = LMimpad('', T, [thSize thSize]+6, 255);
                
                %thumb = LMobjectThumbnail(D(i).annotation, img, o(n), [64 64]);
                
                
                %T = thumb(:,1:end/2-1,:);
                instancesCounts(d(n)) = instancesCounts(d(n))+1;
                folder = fullfile(homethumbnails, sprintf('obj_%d', d(n)));
                filename = fullfile(folder, sprintf('ins_%d.jpg', instancesCounts(d(n))));
                
                mkdir(folder)
                imwrite(T, filename, 'jpg', 'quality', 90)
                
                imshow(T)
                size(T)
                drawnow
            end
        catch
            a = lasterror;
            problems = [problems; a.message];
        end
    end
end
    



