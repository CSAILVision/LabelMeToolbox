function img = imageadjust(img, low, high, sigma)
% 
% img = imadjust(img, low, high, sigma)

img = double(img);

if nargin > 3
    img = gaussian(img, sigma);
end

L = nanmean(img,3);
mi = prctile(L(:), low);
mx = prctile(L(:), high);
img = img - mi;
img = uint8(255*img / (mx-mi));




function img = gaussian(img, sigma)
%
% sigma = width of the gaussian.
%



gx = exp (- (-3*sigma:1:3*sigma).^2 / sigma^2);
gx = gx / sum(gx(:));

img = convn(img, gx, 'same');
img = convn(img, gx', 'same');

