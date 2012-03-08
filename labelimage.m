function bb = labelimage(img, annotation)
% bb = labelimage(img)
%
% It returns bounding boxes. It does not ask for object names. 
% Simple script to label bounding boxes on an image.
%
% Use the online tool for labeling!
% 
% Output:
%   bb = bounding boxes. Each row is [xmin ymin width height]

figure
if nargin == 2
    LMplot(annotation, img);
    legend off
else
    imshow(uint8(img))
end
axis('equal');
axis('off')
h = gca;
title('To draw a rectangle hold the button down and move the mouse. To end, click on the image.')
bb = [];
n = 0;
while 1    
    n = n+1;
    rect = getrect;
    if max(rect(3:4))<2 | rect(1)<-2
        break
    end
    hr = imrect(h, rect);
    bb(n,:) = rect;
end


