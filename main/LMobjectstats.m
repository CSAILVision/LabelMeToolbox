function [objectnames, instancecounts, areacounts, minarea] = LMobjectstats(D, HOMEIMAGES)
% 
% Creates a matrix with object counts:
%
% [objectnames, instancecounts] = LMobjectstats(D);
%
% instancecounts(i,j) = number of times object class i is present in image j.
%    j is the index to the image D(j)
%    i is the index for an object class objectnames{i}
%
% [objectnames, instancecounts, areacounts, minarea] = LMobjectstats(D, HOMEIMAGES);
%
% areacounts(i,j) = proportion of pixels occupied by object class i in
%    image j.

% Created: A. Torralba, 2006

objectnames = LMobjectnames(D);

Nimages = length(D);
Nobjects = length(objectnames);

%instancecounts = zeros([Nobjects, Nimages], 'uint16');
%areacounts = zeros([Nobjects, Nimages], 'single');
instancecounts = sparse(Nobjects, Nimages);
areacounts = sparse(Nobjects, Nimages);
minarea = ones(Nobjects, Nimages);

for i = 1:Nimages
    disp(Nimages-i)
    if isfield(D(i).annotation, 'object')
        if (nargout == 2 || nargout == 0 ) && nargin == 1
            objectsinimage = {D(i).annotation.object.name};
            
            [TF, ndx] = ismember(strtrim(lower(objectsinimage)),lower(objectnames));
            for n = 1:length(ndx)
                instancecounts(ndx(n),i) = instancecounts(ndx(n),i)+1;
            end
        else
            %[mask, objectsinimage] = LMobjectmask(D(i).annotation, HOMEIMAGES);
            objectsinimage = {D(i).annotation.object.name};
            %img = LMimread(D, i ,HOMEIMAGES);
            a = imfinfo(fullfile(HOMEIMAGES, D(i).annotation.folder, D(i).annotation.filename));
            nrows = double(a.Width);
            ncols = double(a.Height);
            %[nrows ncols no] = size(img);
            
            [TF, ndx] = ismember(strtrim(lower(objectsinimage)),lower(objectnames));
            for n = 1:length(ndx)
                [X,Y] = getLMpolygon(D(i).annotation.object(n).polygon);
                area = polyarea(double(X),double(Y)); % ignores intersections
                
                instancecounts(ndx(n),i) = instancecounts(ndx(n),i)+1;
                areacounts(ndx(n),i) = areacounts(ndx(n),i) + area/nrows/ncols;
                minarea(ndx(n),i) = min(minarea(ndx(n),i), area/nrows/ncols);
                %areacounts(ndx(n),i) = areacounts(ndx(n),i) + sum(sum(mask(:,:,n), 1),2)/nrows/ncols;
            end
        end
    end
end


if nargout == 0
    frequency = full(sum(instancecounts,2));
    [ff, ndx] = sort(frequency, 'descend');

    % Show object counts sorted by frequency
    nn = min(40, length(ndx));
    figure
    subplot(221)
    barh(frequency(ndx(1:nn)))
    set(gca, 'YTick', 1:nn)
    set(gca, 'YtickLabel', objectnames(ndx(1:nn)))
    axis([0 max(frequency)+5 0 nn+1])
    grid on
    title(sprintf('number polygons: %d, number classes: %d', sum(frequency), length(frequency)))
    axis('tight')

    
    % SCENE TYPES:
    % 1) ignore images that are not fully annotated
    subplot(222)
    loglog(ff)
    axis('tight'); axis('square');
    xlabel('rank'); ylabel('counts')
    valid = find(full(sum(areacounts>0.05,1)>0) & full(sum(areacounts,1)>.9));
    scenes = (areacounts(:,valid)>0.05);
    [scenesunique, i, j] = unique(scenes', 'rows');
    scenesunique = full(scenesunique');
    ju = unique(j);
    counts = hist(j, ju);
    [foo, ndx] = sort(counts, 'descend');
    
    clear scenenames
    nn = min(20, length(ndx));
    for k = 1:nn
        o = find(scenesunique(:,ndx(k)));
        objectnames{o}
        scenenames{k} = sprintf('%s,',objectnames{o});
    end
    
end

return


    subplot(223)
    % histogram of most frequent scenes
    barh(counts(ndx(1:nn)))
    set(gca, 'YTick', 1:nn)
    set(gca, 'YtickLabel', scenenames(1:nn))
    axis([0 max(frequency)+5 0 nn+1])
    grid on
    axis('tight')

    % number of different scenes
    subplot(224)
    loglog(sort(counts, 'descend'), 'r')
    xlabel('scene rank')
    ylabel('counts')
    axis('tight')
    title('number of scenes')
    
    
    % Visualize examples of most common scenes
    for q = 1:10
        f = find(j==ju(ndx(q)));
        f = f(1:min(36,length(f)));
        LMdbshowscenes(D(valid(f)), HOMEIMAGES)
    end
end







