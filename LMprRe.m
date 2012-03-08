function [RET, REL, RETREL, ndx] = LMprRe(retrievedBoundingBox, annotation, objectname, mindetectablesize)
% This function returns one point in the precision-recall curve.
% Provided a set of detected bounding boxes, it indicates how may objects
% have been detected (RETREL).
%
% The standard measures for IR are recall and precision. Assuming that:
%
%    * RET is the set of all items the system has retrieved for a specific inquiry;
%    * REL is the set of relevant items for a specific inquiry;
%    * RETREL is the set of the retrieved relevant items 
%
% then precision and recall measures are obtained as follows:
%
%    precision = RETREL / RET
%    recall = RETREL / REL 


% Search the target object in the annotation
j = LMobjectindex(annotation, objectname);

% Do not consider deleted objects:
j = j(find(strcmp({annotation.object(j).deleted}, '0')));

Ninstances = length(j);

% Extract the bounding boxes for each target present in the image
BoundingBox = []; REL = 0;
for i = 1:Ninstances
    [X,Y] = getLMpolygon(annotation.object(j(i)).polygon);
    BoundingBox = [BoundingBox; min(X) max(X) min(Y) max(Y)];
   
    % If we detect an object that we thought was too small, we should not
    % penalize performance for this. So, we will consider that the only
    % relevant targets are the ones with a size larger than the minimal
    % detectable size. 
    if max(Y)-min(Y)>mindetectablesize(1) & max(X)-min(X)>mindetectablesize(2) & max(Y)>0 & max(X)>0
        REL = REL + 1;
    end
end

RET = size(retrievedBoundingBox, 1);

if REL == 0 
    RETREL = 0;
    return
end

cxO = mean(BoundingBox(:,1:2),2);
cyO = mean(BoundingBox(:,3:4),2);
DxO = diff(BoundingBox(:,1:2),1,2);
DyO = diff(BoundingBox(:,3:4),1,2);

cxR = mean(retrievedBoundingBox(:,1:2),2);
cyR = mean(retrievedBoundingBox(:,3:4),2);
DxR = diff(retrievedBoundingBox(:,1:2),1,2);
DyR = diff(retrievedBoundingBox(:,3:4),1,2);

ndx = [];
for i = 1:RET
    d = sqrt(((cxR(i) - cxO)./DxO).^2 + ((cyR(i) - cyO)./DyO).^2)<.5 ...
        & max(DxO/DxR(i), DxR(i)./DxO)<1.5 ...
        & max(DyO/DyR(i), DyR(i)./DyO)<1.5;
    n = find(d);
    if length(n)>0
        ndx(i) = n(1);
    else
        ndx(i) = 0;
    end
end
RETREL = sum(unique(ndx)>0); % each object can be detected only once

% If we detect an object that we thought was too small, we should not
% penalize performance for this. So, if we detected one object that was not
% considered before within the relevan set, then we will move it into the
% relevant set:
REL = max(REL, RETREL);



