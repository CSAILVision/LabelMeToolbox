function sptHistObjects = objhist(seg, Nobjects)
% 
% Compute spatial histograms of object labels using the segmentations
%
% h = objhist(seg)
%
% 

Nw = 2;

[nrows, ncols, Nimages] = size(seg);

% Create vector of object counts
if nargin == 1
    Nobjects = double(max(max(max(seg))));
end

sptHistObjects = zeros([Nobjects*(Nw^2+1) Nimages], 'single');
for i = 1:Nimages
    sptHistObjects(:,i) = spatialHistogram(double(seg(:,:,i)), Nw, Nobjects);
end



function h = spatialHistogram(W, Mw, Nwords)
% Mw = number of spatial windows for computing histograms
coef = 1./[2^(Mw-1) 2.^(Mw-(1:(Mw-1)))];

h = [];
for M = 1:Mw
    lx = round(linspace(1, size(W,2)-1, 2^(M-1)+1));
    ly = round(linspace(1, size(W,1)-1, 2^(M-1)+1));
    for x = 1:2^(M-1)
        for y = 1:2^(M-1)
            ww = W(ly(y)+1:ly(y+1), lx(x)+1:lx(x+1));
            hh = hist(ww(:), 1:Nwords);
            h = [h coef(M)*hh];
        end
    end
end

% store words
h = h /sum(h);


