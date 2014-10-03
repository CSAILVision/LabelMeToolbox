function [imgc, x1, x2, y1, y2] = removeFrame(img, framecolor)
%
% Removes a frame from a picture
%
% [imgc, xmin, xmax, ymin, ymax] = removeFrame(img, framecolor);



img = double(img);
[nrows ncols cc] = size(img);

if nargin == 1
    cf = squeeze(median(img(:,5,:),1)); % color frame (a vertical column of uniform color)
else
    cf = framecolor;
end

frame = (abs(img(:,:,1)-cf(1))+abs(img(:,:,2)-cf(2))+abs(img(:,:,3)-cf(3)))<20; % find frame pixels

bx = sum(frame,1)>(nrows*.9);
by = sum(frame,2)>(ncols*.9);

if sum(bx)+sum(by)>5
    mx = round(ncols/2);
    my = round(nrows/2);
    
    x1 = 2+max([-1 max(find(bx(1:mx)))]);
    x2 = -2+min([ncols+2 mx+min(find(bx(mx:ncols)))]);
    y1 = 2+max([-1 max(find(by(1:my)))]);
    y2 = -2+min([nrows+2 my+min(find(by(my:nrows)))]);
    
    imgc = uint8(img(y1:y2, x1:x2, :));
else
    x1 = 1;
    y1 = 1;
    x2 = ncols;
    y2 = nrows;
    imgc = img;
end

