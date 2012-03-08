function showColorSIFT(SIFT)
%
% It reduces the dimensionality of SIFT to 3 dimensions and outputs a color
% coded image
%
% It will map the first PCA dimension to luminance (R+G+B), then it will
% map the second to R-G and the third one to (R+G)/2-B

load ('pcSIFT', 'pcSIFT')

[nrows ncols nfeatures nimages] = size(SIFT);
SIFTcolor = zeros([nrows ncols 3 nimages], 'uint8');
for n = 1:nimages
    SIFTpca = pcSIFT(:,1:3)'*single(reshape(SIFT(:,:,:,n), [nrows*ncols nfeatures]))';

    A = inv([1 1 1; 1 -1 0; .5 .5 -1]);
    %A = eye(3,3);

    tmp = A * SIFTpca(1:3,:);
    tmp = reshape(tmp', [nrows ncols 3]);
    tmp = tmp - min(tmp(:));
    SIFTcolor(:,:,:,n) = uint8(255*tmp / max(tmp(:)));
end

if nimages == 1
    imshow(SIFTcolor)
else
    montage(SIFTcolor)
end

