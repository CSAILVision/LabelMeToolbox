function LMstats(D, HOMEIMAGES)

D = LMvalidobjects(D);
%objectnames = lower(LMobjectnames(D));
[D, objectnames] = LMcreateObjectIndexField(D);
objectnames = lower(objectnames);
Nimages = length(D);
Nobjects = length(objectnames);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect data: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
instancecounts = sparse(Nobjects, Nimages);
areacounts = sparse(Nobjects, Nimages);
labelingdate = [];
imagendx = [];
objndx = [];

p = 0;
for n = 1:Nimages
    Nimages - n
    if isfield(D(n).annotation, 'object')
        objectsinimage = {D(n).annotation.object.name};
        
        %a = imfinfo(strrep(fullfile(HOMEIMAGES, D(n).annotation.folder, D(n).annotation.filename), '\', '/'));
        %nrows = a.Width;
        %ncols = a.Height;
        
        ncols = 0; nrows = 0;
        [TF, ndx] = ismember(strtrim(lower(objectsinimage)), objectnames);
        for m = 1:length(ndx)
            [X,Y] = getLMpolygon(D(n).annotation.object(m).polygon);
            area = polyarea(double(X),double(Y)); % ignores intersections

            instancecounts(ndx(m),n) = instancecounts(ndx(m),n)+1;
            areacounts(ndx(m),n) = areacounts(ndx(m),n) + area;
            nrows = max(nrows, max(Y(:)));
            ncols = max(ncols, max(X(:)));
        end
        areacounts(:,n) = areacounts(:,n) / double(nrows*ncols);

        % Collect date
        if isfield(D(n).annotation.object(1), 'date')
            for m = 1:length(D(n).annotation.object)
                d = D(n).annotation.object(m).date;
                if ~isempty(d)
                    p = p + 1;
                    labelingdate{p} = d(1:11);
                    imagendx(p) = n;
                    objndx(p) = D(n).annotation.object(m).namendx;
                end
            end
        end
    end
end
Labelingdate = datenum(labelingdate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plots:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OBJECTS
% 1) distribution object labels
frequency = full(sum(instancecounts,2));
[sortedFreq, ndx] = sort(frequency, 'descend');

% Show object counts sorted by frequency
nn = min(40, length(ndx));
figure
subplot(121)
loglog(sortedFreq)
xlabel('rank')
ylabel('counts')
title('Distribution of objects')
axis('square'); axis('tight')
subplot(122)
barh(frequency(ndx(1:nn)))
set(gca, 'YTick', 1:nn)
set(gca, 'YtickLabel', objectnames(ndx(1:nn)))
axis([0 max(frequency)+5 0 nn+1])
grid on
title(sprintf('Most frequent obj. Number polygons: %d, number classes: %d', sum(frequency), length(frequency)))
axis('tight')

% histogram of number of objects per image
valid = find(full(sum(areacounts,1)>.97));
imagesperobject = full(sum(instancecounts,1));
figure
hist(imagesperobject(valid), [1:200])
xlabel('number of objects/image')
ylabel('counts')
title('Histogram of number of objects per image')



% 2) evolution dataset/time
lastDate = max(Labelingdate);
year = [2005 2006 2007 2008 2009 2010]
months = [1:12]
t = 0; dt = []; 
counts = []; 
countUniqueImages = [];
countObjectClasses = [];
for y = year
    for m = months
        t = t+1;
        d = (datenum(y,m,31));
        if d<lastDate

            dt{t} = datestr(d);
            j = find(Labelingdate<d);
            counts(t) = length(j);
            countUniqueImages(t) = length(unique(imagendx(j)));
            countObjectClasses(t) = length(unique(objndx(j)));
        else
            break
        end
    end
end

if length(dt)>48
init = 5;
figure
subplot(311)
plot(counts(init:end))
set(gca,'Xtick',[1 12 24 36 48]-init+1)
set(gca,'XTickLabel', dt([1 12 24 36 48]));
subplot(312)
plot(countUniqueImages(init:end),'r')
set(gca,'Xtick',[1 12 24 36 48]-init+1)
set(gca,'XTickLabel', dt([1 12 24 36 48]));
subplot(313)
plot(countObjectClasses(init:end),'g')
set(gca,'Xtick',[1 12 24 36 48]-init+1)
set(gca,'XTickLabel', dt([1 12 24 36 48]));
end

% 3) perplexity labels / proportion new labels added every day


% SCENES
% 4) distribution of scenes: if a scene is defined as the 5 largest
% objects: draw distribution of scene types. 
Nobj = 4;
valid = find(full(sum(areacounts>0.05,1)>0) & full(sum(areacounts,1)>.97));
valid = find(full(sum(areacounts,1)>.97));
% for each scene collect only the 5 largest objects
scenes = sparse(Nobjects, Nimages);
for i = valid
    s = full(areacounts(:,i));
    jj = find(s>0);
    [ss,j] = sort(s(jj),'descend');
    
    L = min(length(j),Nobj);
    j = jj(j(1:L));
    
    scenes(j,i) = 100-(0:L-1);
end
scenes = scenes(:,valid)';

colors = 'rgcb'; k = 0;
figure
for ngram = [1 2 4 8]
    k = k+1;
    S = (scenes>100-ngram);
    % remove scenes with less than ngram objects
    c = sum(S,2);
    svalid = find(c>=ngram);
    
    [scenesunique, ns, j] = unique(S(svalid,:), 'rows');
    ns = valid(svalid(ns)); % recover initial indexing
    scenesunique = full(scenesunique');
    ju = unique(j);
    counts = hist(j, ju);
    [counts, ndx] = sort(counts, 'descend');

    loglog(counts, colors(k))
    hold on
    title('Distribution of scenes: a scene is a unique N-gram')
    axis('square'); axis('tight')
    drawnow
end
axis([1 3000 .9 3000])

% Create figure with most common scene within each scene type: look at the
% most frequent distribution of the other objects. Take the image closer to
% the mean. Make a figure with 10 different scene types.
ngram = 4;
S = (scenes>100-ngram);
c = sum(S,2);
svalid = find(c>=ngram);
[scenesunique, ns, j] = unique(S(svalid,:), 'rows');
ns = valid(svalid(ns)); % recover initial indexing
scenesunique = full(scenesunique');
ju = unique(j);
counts = hist(j, ju);
[counts, ndx] = sort(counts, 'descend');

figure
k=0;
for n = 1:1:49
    k = k+1;
    % get list of large objects in image
    o = find(scenesunique(:,ndx(n)));
    list = sprintf('%s,',objectnames{o}); 
    list = sprintf('%s (%d)', list(1:end-1), counts(n));
    
    % get typical scene from set
    img = LMimread(D, ns(ndx(n)), HOMEIMAGES);
    thumb = LMsceneThumbnail(D(ns(ndx(n))).annotation, HOMEIMAGES, img);
    
    subplottight(7,7,k,.1)
    imshow(thumb)
    title(list)
    drawnow
end
% 5) perplexity scenes


% TYPICALITY
% Show the most typical scene. Or run Kmeans using the distances and chose the 10 central images. The one with the lowest perplexity.




