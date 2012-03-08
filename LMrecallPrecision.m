function [recall, precision, Dd, threholds, score, correct, averagePrecision, countsDetectionsPerImage, countsCorrectDetectionsPerImage, countsTrueObjectsPerImage, correctPerImage] = LMrecallPrecision(Dgt, Dd, objectname, method)
% Plots a precision-recall curve.
%
%  [recall, precision, Doutput, threholds, score, correct, countsDetectionsPerImage, countsCorrectDetectionsPerImage, countsTrueObjectsPerImage]=LMrecallPrecision(Dgt, Dd, objectname);
%
% It uses two matlab structs:
%     Dgt = groundtruth dataset
%     Dd =  detection dataset
% 
% The groundtruth dataset is a struct that can be the result of a query.
% The detection struct, is the output of a detector. It is supposed to have
% the same structure than the groundtruth dataset. It should be as if a
% human had labeled the images.
%
% There should be an additional field indicating the detectors confidende:
%     detection.annotation.object.confidence
%
% So, the detector should generate a struct with the next fields:
%            detection(n).annotation.filename =  STRING
%            detection(n).annotation.folder   =  STRING 
%            detection(n).annotation.object(kn).name =  STRING
%            detection(n).annotation.object(kn).confidence =  DOUBLE
%            detection(n).annotation.object(kn).polygon.pt(i).x = STRING
%            detection(n).annotation.object(kn).polygon.pt(i).y = STRING
%
%  where i = 1:4 for the four corners of the bounding box (the order does not matter)
%  kn loops on all the objects present on image n
%  n loops on the images on the dataset
%
%
%  VISUALIZATION DETECTION RESULTS:
%
%
%  The function generates a new struct with all the detections labeled as correct detections or false alarms. 
%  It also inserts all the missed object instances. This information
%  appears in the field 'object.detection'. If you want to visualize the
%  false alarms, you can use the LMquery function as follows:
% 
%  LMdbshowscenes(LMquery(Doutput, 'object.detection', 'false'), HOMEIMAGES)
%
%  To visualize the missed objects:
%
%  LMdbshowscenes(LMquery(Doutput, 'object.detection', 'missed'), HOMEIMAGES)

% Needs to be done:
%   - multiclass
%   - better assignment of bounding boxes to detections. Make sure that the
%   procedure does not inflate performances. It should be an "honest"
%   assignment...

if nargin<4
    method = '';
    
end
successThreshold = 0.5;

NimagesGt = length(Dgt);
NimagesD = length(Dd);

if NimagesGt~=NimagesD
    error('Both database structs should be computed on the same images. D1 and D2 have different number of images.');
end

score = [];
correct = [];
countsDetectionsPerImage = zeros([1, NimagesGt]);
countsCorrectDetectionsPerImage = zeros([1, NimagesGt]);
countsTrueObjectsPerImage = zeros([1, NimagesGt]);
correctPerImage = sparse(10, NimagesGt);  % Assume that the maximum number of candidate windows is 10.
Ntargets = 0;


disp('evaluating precision-recall')
for i = 1:NimagesGt
    % find objects
    valid_gt = LMobjectindex(Dgt(i).annotation, objectname, 'exact');
    valid_d = LMobjectindex(Dd(i).annotation, objectname, 'exact');
    
    % Get polygons from ground truth -> bounding boxes
    Bt = LMobjectboundingbox(Dgt(i).annotation, valid_gt);
    Ngt = size(Bt,1);

    % Get polygons detection
    Bd = LMobjectboundingbox(Dd(i).annotation, valid_d);
    Nd = size(Bd,1);
    
    if Nd>0
        confidence = [Dd(i).annotation.object(valid_d).confidence];
    else
        confidence = [];
    end

    % Compute overlappings between bounding-boxes
    if Nd>0 && Ngt>0    
        overlap = overlapping(Bd, Bt);
        
        % Assign detections to ground truth targets. First start with the most confident detections.
        % Once a target gets assigned to one detection, that target cannot be used again
        % and the rest of detections are labeled as false alarms.
        [foo,s] = sort(confidence, 'descend');
        
        td = zeros(Nd,1);
        
        for n = s
            [ovmax, jmax] = max(overlap(n,:));
            
            if ovmax>=successThreshold
                if ~ismember(jmax, td)
                    td(n)=jmax;
                end
            end
        end
        
        falseAlarms = find(td==0);
        correctDetections = find(td>0);
        missedTargets = setdiff(1:Ngt, td);        
    else
        % no true detections
        correctDetections = [];
        % all targets are missed
        missedTargets = 1:Ngt;
        % all detections are false alarms
        falseAlarms = 1:Nd;
    end

    % scores
    if Nd>0
        score = [score confidence];
        cr = zeros(1,Nd); 
        cr(correctDetections)=1;
        correct = [correct cr];
        
        countsDetectionsPerImage(i) = Nd;
        countsTrueObjectsPerImage(i) = Ngt;
        countsCorrectDetectionsPerImage(i) = length(correctDetections);
        correctPerImage(correctDetections,i) = 1;
    end
    Ntargets = Ntargets + Ngt;
    
    % Insert tags:
    % translate to true indices
    correctDetections = valid_d(correctDetections); % correct detections index detector struct
    falseAlarms = valid_d(falseAlarms); % false alarms index detector struct
    missedTargets = valid_gt(missedTargets); % missed targets index to ground truth struct
    
    % insert tags
    for a = 1:length(falseAlarms)
        Dd(i).annotation.object(falseAlarms(a)).detection='false';
    end
    for a = 1:length(correctDetections)
        Dd(i).annotation.object(correctDetections(a)).detection='correct';
    end
    
    if ~strcmp(method, 'nomisses')
        % insert misses
        %Nobj = length(Dd(i).annotation.object);
        Nobj = Nd;
        for a = 1:length(missedTargets)
            Dd(i).annotation.object(Nobj+a).name = Dgt(i).annotation.object(missedTargets(a)).name;
            Dd(i).annotation.object(Nobj+a).deleted = '0';
            Dd(i).annotation.object(Nobj+a).polygon = Dgt(i).annotation.object(missedTargets(a)).polygon;
            Dd(i).annotation.object(Nobj+a).detection='missed';
        end
    end
end

% Compute Precision-Recall
[S,j] = sort(score, 'descend'); % retrieved elements are the ones above or equal to the threshold
C = correct(j);
n = length(C);

REL    = Ntargets
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



% compute average precision (from PASCAL source code)
ap=0;
T = linspace(0,1,11);
for t=T % why so few bins?
    p=max(precision(recall>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/length(T);
end
averagePrecision = ap;


function overlap = overlapping(A, B)

n = size(A,1);
m = size(B,1);
overlap= zeros(n,m);

for i = 1:n
    Ai = A(i,:);
    areaA = (Ai(3)-Ai(1)+1)*(Ai(4)-Ai(2)+1);
    for j = 1:m
        Bj = B(j,:);
        areaB = (Bj(3)-Bj(1)+1)*(Bj(4)-Bj(2)+1);
        
        intAB = [max(Ai(1),Bj(1)) ; max(Ai(2),Bj(2)) ; min(Ai(3),Bj(3)) ; min(Ai(4),Bj(4))];
        areaAB = max(0, (intAB(3)-intAB(1)+1)*(intAB(4)-intAB(2)+1));
        
        overlap(i,j) = areaAB / (areaA + areaB - areaAB);
        
        if areaA<0; pepe; end
        if areaB<0; pepe; end
    end
end

%function Bd = boundingboxfast(Dd(i).annotation.object(valid_d));



