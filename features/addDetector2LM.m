function annotation = addDetector2LM(boundingBox, boxScores, boxClass, annotation)
%
% annotation = addDetector2LM(boundingBox, boxScores, boxClass, annotation)
%
% Input
%    boundingBox: matrix [Nobjects x 4]. Each row is boundingBox(i,:) = [xmin xmax ymin ymax]
%    boxScores  : vector [Nobjects]
%    boxClass   : string with the object name. I assume all bounding boxes
%                 belong to a single class
%    annotation : the object will be added to the annotation struct
%                 (optional)
%
% Output
%    annotation 


nDetections = size(boundingBox, 1);


% check if there are other objects
nObjects = 0;

if nargin == 4
    if isfield(annotation, 'object')
        nObjects = length(annotation.object);
    end
else
    annotation = [];
end


% Translate bounding boxes into LabelMe format:
if nDetections>0
    k = nObjects;
    for i = 1:nDetections;%1:nDetections
        k = k+1;
        annotation.object(k).name = boxClass;
        annotation.object(k).confidence = boxScores(i);
        %X = [boundingBox(i,1) boundingBox(i,2) boundingBox(i,2) boundingBox(i,1) boundingBox(i,1)];
        %Y = [boundingBox(i,3) boundingBox(i,3) boundingBox(i,4) boundingBox(i,4) boundingBox(i,3)];
        
        X = [boundingBox(i,1) boundingBox(i,2) boundingBox(i,2) boundingBox(i,1)];
        Y = [boundingBox(i,3) boundingBox(i,3) boundingBox(i,4) boundingBox(i,4)];

        annotation.object(k).polygon = setLMpolygon(X,Y);
        annotation.object(k).deleted = 0;
        annotation.object(k).date = '';
        annotation.object(k).id = i;
    end
end
