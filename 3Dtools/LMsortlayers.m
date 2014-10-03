function [annotation, j, layers] = LMsortlayers(annotation, img)
%
% annotation = LMsortlayers(annotation)
%
% Returns the same annotation file, but the objects are sorted by depth. We
% assume that each object belongs to a single layer.
%
% The output polygons are sorted from far to close.

j = [];
layers = [];

if ~isfield(annotation, 'object')
    return
end

Nobjects = length(annotation.object);

if Nobjects == 1
    return
end

% List of objects that are allways in the farthest layers (nothing can be
% bellow them):
background = {'sky', 'road', 'sidewalk', 'wall', 'floor', 'carpet', 'ceiling'};
jback = [];
for m = 1:length(background)
    jc = LMobjectindex(annotation, background{m});
    if length(jc)>0
        jback = [jback jc];
    end
end
layers = zeros(length(jback), 1); 
%jback=[];

% Sort objects by size
[nrows, ncols, cc] = size(img);
jobj = setdiff(1:Nobjects, jback);
Nobj = length(jobj);
mask = zeros([nrows ncols Nobj], 'single');
if length(jobj)>0
    objarea = zeros(length(jobj),1);
    for k = 1:length(jobj)
        [X,Y] = getLMpolygon(annotation.object(jobj(k)).polygon);
        mask(:,:,k) = poly2mask(double(X),double(Y),nrows,ncols);
    end
    intersection = reshape(mask,[nrows*ncols Nobj]);
    intersection = intersection'*intersection;
    objarea  = eps+diag(intersection);

    % Row i is normalized by the area of object i: intersection(i,j) =
    % proportion of object i occupied by object j
    intersection = intersection./repmat(objarea, [1 Nobj]);
    intersection = intersection .*(intersection>.05);
     
    % OnTop(i,j) = 1 => object i is on top of object j
    OnTop = intersection>.9; % If polygon i is included in j, then obj i is on top of j

    % For objects with partial overlap, we have to see who owns the area of intersection
    [obj1, obj2] = find(triu((max(intersection,intersection')>0.05).*(OnTop+OnTop'==0)));

    % Only need to be sorted objects that have intersections with others.
    for i = 1:length(obj1)
        [x1,y1] = getLMpolygon(annotation.object(jobj(obj1(i))).polygon);
        [x2,y2] = getLMpolygon(annotation.object(jobj(obj2(i))).polygon);
        [order, confidence] = densitypolygon(x1,y1,x2,y2);

        if confidence < 2
            order = classifyregion(img, mask(:,:,obj1(i)), mask(:,:,obj2(i)));
        end
        
        if order == 1
            % obj1 on top of obj2
            OnTop(obj1(i), obj2(i)) = 1;
        else
            % obj2 on top of obj1
            OnTop(obj2(i), obj1(i)) = 1;
        end
    end

    % sort objects
    ndx = [];
    Layer = 0;
    
    % Sorted from back to front: the first object should be bellow of all
    OnTop = OnTop - diag(diag(OnTop));
    while length(ndx)<Nobj
        j = find((sum(OnTop,2)) == 0); % this are objects on top of nothing
        j = setdiff(j,ndx);
        
        if length(j) == 0;
            j = setdiff(1:Nobj, ndx)';
            [foo, jj] = sort(-objarea(j)); j = j(jj);
            ndx = [ndx; j];
            Layer = Layer+1;
            layers = [layers; Layer*ones(length(j),1)];
            break;
        else
            ndx = [ndx; j];
            Layer = Layer+1;
            layers = [layers; Layer*ones(length(j),1)];
        end
        
        for m = 1:length(j); 
            OnTop(j(m),:) = 0; OnTop(:,j(m)) = 0; 
        end
    end
    
    
    %[objarea, ndx] = sort(-objarea);
    j = [jback jobj(ndx)];
else
    j = jback;
end
annotation.object = annotation.object(j);

function [ontop, confidence] = densitypolygon(x1,y1,x2,y2)
% Sorts the masks by counting number of points inside the region. 
%

inside1 = sum(inpolygon(x2,y2,x1,y1));
inside2 = sum(inpolygon(x1,y1,x2,y2));
confidence = abs(inside1-inside2);

if inside1 > inside2
    ontop = 2;
else
    ontop = 1;
end


function [ontop, confidence] = classifyregion(img, m1, m2)
% Returns the depth ordering of the segmentation masks 'm1' and 'm2'
% It only works if the two regions overlap
%
% For overlaping objects, decide which one is on top by looking to who owns
% the region of intersection

% img = convn(single(img), [-1 -1 -1; -1 12 -1; -1 -1 -1], 'same');
% %img = convn(double(img), [1 2 1;2 4 2;1 2 1]/16, 'same');
% img = img - min(img(:));
% img = uint8(255*img / max(img(:)));

[nrows, ncols, c] = size(img);
confidence = 0;

% crop image around intersection area
B = 100;
[y,x] = find((m1.*m2)==1);
Nbins = 5;
if length(x)>5
    xmin = max(1, min(x)-B);
    xmax = min(ncols, max(x)+B);
    ymin = max(1, min(y)-B);
    ymax = min(nrows, max(y)+B);
    
    img = single(img(ymin:ymax, xmin:xmax,:));
    m1 = m1(ymin:ymax, xmin:xmax);
    m2 = m2(ymin:ymax, xmin:xmax);

    img = img-min(img(:));
    img = uint8(255*img/max(img(:)));
    if size(img,3)==3
        img = 255*rgb2hsv(img);
    else
        img = repmat(img,[1 1 3]);
    end
    
    %m1 = m1c;
    %m2 = m2c;

%     vert = log(1+abs(conv2(mean(imgc,3), [-1 2 -1; -1 2 -1; -1 2 -1], 'same')));
%     vert = vert-min(vert(:));
%     vert = 255*vert/max(vert(:));
% 
%     hor = log(1+abs(conv2(mean(imgc,3), [-1 2 -1; -1 2 -1; -1 2 -1]', 'same')));
%     hor = hor-min(hor(:));
%     hor = 255*hor/max(hor(:));

    %colorch = (imgc(:,:,1) - imgc(:,:,2)) ./ (1+imgc(:,:,1)+imgc(:,:,2));
    
    %colorch = mean(imgc,3);
    %imgc = imgc(:,:,1:1);
    img2 = reshape(img, [size(img,1)*size(img,2) size(img,3)]);
    %img2(:,4) = mean(img2,2);
    %img2(:,1) = vert(:);
    %img2(:,2) = hor(:);
    %img2 = colorch(:);
    
    j1 = find((m1==1).*(m2==0));
    j2 = find((m2==1).*(m1==0));
    jint = find((m1.*m2)==1);

    %bins = linspace(1, 256, 100);
    h1 = hist4(img2(j1,:), Nbins); 
    h2 = hist4(img2(j2,:), Nbins);     
    hint = hist4(img2(jint,:), Nbins);     
    
    %h1 = hist(img2(j1,:), bins); 
    h1 = h1/length(j1); h1 = h1(:);
    %h2 = hist(img2(j2,:), bins); 
    h2 = h2/length(j2); h2 = h2(:);
    %hint = hist(img2(jint,:), bins); 
    hint = hint/length(jint); hint = hint(:);

    score1 = sum(min(h1, hint));
    score2 = sum(min(h2, hint));
    %score1 = sum(((h1-hint)./(eps+hint)).^2);
    %score2 = sum(((h2-hint)./(eps+hint)).^2);
    %score1 = sum(h1.*hint);
    %score2 = sum(h2.*hint);
    confidence = abs(score1-score2);
    
    if score2 > score1
        ontop = 2;
    else
        ontop = 1;
    end
    
%     figure(2); clf
%     subplot(431)
%     imshow(uint8(img).*uint8(repmat(m1.*(m2==0), [1 1 3])))
%     subplot(432)
%     imshow(uint8(img).*uint8(repmat(m2.*(m1==0), [1 1 3])))
%     subplot(433)
%     imshow(uint8(img).*uint8(repmat(m1.*m2, [1 1 3])))
%     title('intersection')
%     subplot(434)
%     plot(h1)
%     hold on
%     plot(min(h1, hint),'r')
%     title(score1)
%     subplot(435)
%     plot(h2)
%     hold on
%     plot(min(h2, hint),'r')
%     title(score2)
%     subplot(4,3,6)
%     plot(hint)
%     title('intersection')
%     xlabel(confidence)
%     subplot(4,3,7)
%     imagesc(max(reshape(h1, [Nbins Nbins Nbins]),[],3))
%     axis('square'); axis('off')
%     subplot(4,3,8)
%     imagesc(max(reshape(h2, [Nbins Nbins Nbins]),[],3))
%     axis('square'); axis('off')
%     subplot(4,3,9)
%     imagesc(max(reshape(hint, [Nbins Nbins Nbins]),[],3))
%     colormap(gray(256))
%     axis('square'); axis('off')
%     subplot(4,3,10)
%     imshow(uint8(img).*uint8(repmat(m1.*((m2==0) | ontop==1), [1 1 3])))
%     subplot(4,3,11)
%     imshow(uint8(img).*uint8(repmat(m2.*((m1==0) | ontop==2), [1 1 3])))
else
    % if the intersection is too small, then put the smaller object in
    % front.
    if sum(m1(:))<sum(m2(:))
        ontop = 1;
    else
        ontop = 2;
    end
end


function H = hist4(img, Nbins)

%[ncols nrows c] = size(img);
X = fix(double(img)/256*Nbins) + 1;
%X = reshape(X, [ncols*nrows c]);

n = sub2ind([Nbins Nbins Nbins], X(:,1), X(:,2), X(:,3));
H = hist(n, 1:Nbins*Nbins*Nbins);
%H = reshape(H, [Nbins Nbins Nbins]);


