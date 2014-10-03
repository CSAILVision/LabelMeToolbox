function [recall, precision, Dd, threholds, score, correct] = LMrecallPrecision(Dgt, Dd, objects)
% Plots a precision-recall curve.
%
% It uses two matlab structs:
% Dgt = groundtruth dataset
% Dd =  detection dataset
% 
% The groundtruth dataset is a struct that can be the result of a query.
% The detection struct, is the output of a detector. It is supposed to have
% the same structure than the groundtruth dataset. It should be as if a
% human had labeled the images.
% There should be an additional field indicating the detectors confidende:
% detection.annotation.object.confidence
%
% So, the detector should generate a struct with the next fields:
%            detection(n).annotation.filename =  STRING
%            detection(n).annotation.folder   =  STRING 
%            detection(n).annotation.object(kn).name =  STRING
%            detection(n).annotation.object(kn).confidence =  DOUBLE
%            detection(n).annotation.object(kn).polygon.pt(i).x = STRING
%            detection(n).annotation.object(kn).polygon.pt(i).y = STRING
%
%  where i = 1:4 for the four corners of the bounding box
%  kn loops on all the objects present on image n
%  n loops on the images on the dataset
%

NimagesGt = length(Dgt);
NimagesD = length(Dd);

if NimagesGt~=NimagesD
    error('Both database structs should be computed on the same images. D1 and D2 have different number of images.');
end

score = [];
correct = [];

for i = 1:NimagesGt
    i
    % Get polygons from ground truth -> bounding boxes
    [xt,yt] = LMobjectpolygon(Dgt(i).annotation, objects);
    Bt = LMobjectboundingbox(Dgt(i).annotation, objects);
    Ngt = size(Bt,1);

    % Get polygons detection
    [xd,yd] = LMobjectpolygon(Dd(i).annotation, objects);
    Bd = LMobjectboundingbox(Dd(i).annotation, objects);
    Nd = size(Bd,1);
    
    if Nd>0
        confidence = [Dd(i).annotation.object.confidence];
    else
        confidence = [];
    end

    % Compute overlappings between bounding-boxes
    if Nd>0 && Ngt>0    
        overlap = overlapping(Bd, Bt);
        
        %keyboard
        % Assign detections to ground truth targets. First start with the most confident detections.
        % Once a target gets assigned to one detection, that target cannot be used again
        % and the rest of detections are labeled as false alarms.
        [foo,s] = sort(-confidence);
        nd = [];
        for n = s
            j = setdiff(find((overlap(n,:)>.5) .* (overlap(n,:)>(max(overlap(n,:))-.001))),nd);
            
            if ~isempty(j)
                overlap(n,j)
                nd(n) = j(1);
            else
                nd(n) = -1; % this is a false alarm
            end
        end
        missedTargets = setdiff(1:Ngt, nd);
        falseAlarms = find(nd==-1);
        correctDetections = find(nd>0);
    else
        correctDetections = [];
        % all targets are missed
        missedTargets = 1:Ngt;
        % all detections are false alarms
        falseAlarms = 1:Nd;
    end

    % insert tags
    for a = 1:length(falseAlarms)
        Dd(i).annotation.object(falseAlarms(a)).detection='false';
    end
    for a = 1:length(correctDetections)
        Dd(i).annotation.object(correctDetections(a)).detection='correct';
    end
    
    % scores
    if Nd>0
        score = [score confidence];
        cr = zeros(1,Nd); 
        cr(correctDetections)=1;
        correct = [correct cr];
    end
    
    %Nmissed = length(missedTargets);
    %score = [score -2000+rand(1,Nmissed)];
    %correct = [correct ones(1,Nmissed)];
end

% Compute Precision-Recall
Ntargets = sum(LMcountobject(Dgt, objects));

[S,j] = sort(-score); % retrieved elements are the ones above or equal to the threshold
C = correct(j);
n = length(C);

REL    = Ntargets;
if n>0
    RETREL = cumsum(C);
    RET    = 1:n;
else
    RETREL = 0;
    RET    = 1;
end

precision = RETREL ./ RET;
recall    = RETREL  / REL;
threholds = -S;




function overlap = overlapping(A, B)

n = size(A,1);
m = size(B,1);

intersection = rectint(A,B);
areaA = diag(rectint(A,A));
areaB = diag(rectint(B,B));

overlap= zeros(n,m);
for i = 1:n
    for j = 1:m
        % Union of bounding boxes:
        ua = (areaA(i)+areaB(j)-intersection(i,j));
        
        % PASCAL measure:
        %pp = [min(A(i,1),B(j,1)) min(A(i,2),B(j,2)) max(A(i,1)+A(i,3),B(j,1)+B(j,3))  max(A(i,2)+A(i,4),B(j,2)+B(j,4))];
        %ua = (pp(3)-pp(1))*(pp(4)-pp(2));
        overlap(i,j) = intersection(i,j) / ua;
    end
end
