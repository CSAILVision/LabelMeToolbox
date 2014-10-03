function [boundingbox centers] = LMobjectboundingbox(annotation, name)

% boundingbox = LMobjectboundingbox(annotation, j)
%     returns the bounding box of polygon index j:
%     boundingbox(n,:) = [min(x) min(y) max(x) max(y)];
%
%
% boundingbox = LMobjectboundingbox(annotation, name)
%     returns all the bounding boxes that
%     belong to object class 'name'. Is it an array Ninstances*4
%
% boundingbox = [xmin ymin xmax ymax]
% centers = [x y] is the central point of the bounding box  

if isfield(annotation, 'object')
    if nargin == 1
        jc = 1:length(annotation.object);
    else
        if ischar(name)
            jc = LMobjectindex(annotation, name);
        else
            jc = name;
        end
    end
    
    Nobjects = length(jc);
    if Nobjects == 0
        boundingbox = [];
    else
        boundingbox = zeros(Nobjects,4);
        for n = 1:Nobjects
            [x,y] = getLMpolygon(annotation.object(jc(n)).polygon);
            boundingbox(n,:) = [min(x) min(y) max(x) max(y)];
        end
    end
    if isempty(boundingbox) == 0
        centers = [boundingbox(:,1) + round((boundingbox(:,3)-boundingbox(:,1))/2)  boundingbox(:,2) + round((boundingbox(:,4)-boundingbox(:,2))/2)];
    else
        centers = [];
    end
else
    boundingbox = [];
    centers = [];
end



  