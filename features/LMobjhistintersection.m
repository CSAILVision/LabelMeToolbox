function [objDist, ndx, img, seg, sptCounts, names] = LMobjhistintersection(D, HOMEIMAGES)
%
% Compute distance between images using the annotations. Two images are
% similar if they contain the same objects with roughly the same spatial
% configuration.
%
% Example: compute distance between images and show images in 2D space:
%  [objDist, ndx, thumbsImg, thumbsSeg] = LMobjhistintersection(D, HOMEIMAGES);
%  Y = cmdscale(objDist);
%  showSpaceImages(thumbsImg, Y(:,1), Y(:,2));

thumbnailsize = 48;

% Select images with minimum of 10% labeled pixels
relativearea = LMlabeledarea(D);
ndx = find(relativearea>.1);
D = D(ndx);
relativearea = relativearea(ndx);

% Create segmentations
[img, seg, names, counts] = LM2segments(D, [thumbnailsize+2 thumbnailsize+2], HOMEIMAGES);
img = img(2:end-1,2:end-1,:,:);
seg = seg(2:end-1,2:end-1,:);

% Remove empty images
valid = find(sum(sum(seg>0,1),2)>0);
img = img(:,:,:,valid);
seg = seg(:,:,valid);
ndx = ndx(valid);
[sy sx cc Nimages] = size(img);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create vector of object counts
Nobjects = double(max(max(max(seg))));
Nw = 2;
sptCounts = zeros([Nobjects*(Nw^2+1) Nimages], 'single');
for i = 1:Nimages
    sptCounts(:,i) = spt_hist(double(seg(:,:,i)), Nw, Nobjects);
end
%sptCounts = sptCounts';

% Create matrix of distances between images
[sy sx cc Nimages] = size(img);
objDist = zeros([Nimages, Nimages], 'single');

for i = 1:Nimages
    i
    % histogram intersection
    hi = sptCounts(:,i);
    d = distH(sptCounts, hi);
    objDist(i,:) = d;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = spt_hist(W, Mw, Nwords)
% Spatial pyramid histogram
%
% remove word = 0 (unlabeled)
% Mw = number of spatial windows for computing histograms
coef = 1./[2^(Mw-1) 2.^(Mw-(1:(Mw-1)))];

h = [];
for M = 1:Mw
    lx = round(linspace(0, size(W,2)-1, 2^(M-1)+1));
    ly = round(linspace(0, size(W,1)-1, 2^(M-1)+1));
    for x = 1:2^(M-1)
        for y = 1:2^(M-1)
            ww = W(ly(y)+1:ly(y+1), lx(x)+1:lx(x+1));
            hh = hist(ww(:), 0:Nwords);
            hh = hh(2:Nwords+1); 
            h = [h coef(M)*hh];
        end
    end
end


function d = distH(H1,h2)
% Histogram intersection
% Distance between two histograms (works also if they are not normalized)
%
% h1 = matrix
% h2 = column vector
%
% http://www.ee.columbia.edu/~xlx/courses/vis-hw3/page2.html

[nfeat nvectors] = size(H1);
j = find(h2>0);

d = 1-sum(min(H1(j,:),repmat(h2(j), [1 nvectors])))./max(sum(H1,1),sum(h2));


