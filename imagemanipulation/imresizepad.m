function img = imresizepad(img, M, METHOD, padval)
%
% img = imresizepad(img, [nrows ncols], METHOD, padval);
%
% Resizes the image so that it fits inside a canvas of size [nrows ncols]
% by scaling and padding the image if necesary.
% 



scaling = min(M(1)/size(img,1), M(2)/size(img,2));

newsize = max(1,round([size(img,1) size(img,2)]*scaling));
img = imresize(img, newsize, METHOD);

[foo, img] = LMimpad('', img, M, padval);

