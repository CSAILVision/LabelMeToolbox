function [recall, precision, averagePrecision, Dd, BBd, id_im_d, sc, tp] = LMprecisionRecall2(Dgt, Dd, objectname, objectattributes, draw, minoverlap)

% Computes precision, recall, average precision and plots a precision-recall curve.
%
%  [recall, precision, averagePrecision, Dd] = LMprecisionRecall(Dgt, Dd, objectname, draw)
%
% It uses two matlab structs:
%     Dgt = groundtruth dataset
%     Dd =  detection dataset
% 
% The other inputs are:
%     objectname: object class name
%     draw: if draw=1 it draws the precision-recall curve.
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
%  Detections are assigned to ground truth objects with the same crieterion
%  as in VOC in PASCAL challenge.
%
%  The function generates a new struct with all the detections labeled as correct detections or false alarms. 
%  It also inserts all the missed object instances. This information
%  appears in the field 'object.detection'. 
% 
%  VISUALIZATION DETECTION RESULTS:
% 
% If you want to visualize the
%  false alarms, you can use the LMquery function as follows:
% 
%  LMdbshowscenes(LMquery(Doutput, 'object.detection', 'false'), HOMEIMAGES)
%
%  To visualize the missed objects:
%
%  LMdbshowscenes(LMquery(Doutput, 'object.detection', 'missed'), HOMEIMAGES)


if nargin<5
    draw = 0; 
    if nargin < 4
        objectattributes = '';
    end           
end

if nargin < 6 
    minoverlap = 0.5; 
end

NimagesGt = length(Dgt);
NimagesD = length(Dd);

if NimagesGt ~= NimagesD
    error('Both database structs should be computed on the same images. D1 and D2 have different number of images.');
end

id_im_d = [];
id_object_d = [];
confidence = [];
BBd = [];
npos = 0;
for i = 1:NimagesGt
    % find objects
    valid_gt = LMobjectindex(Dgt(i).annotation, objectname, 'exact');
    if ~isempty(objectattributes) && ~isempty(objectattributes{1})
        valid_gt_at = [];
        for j = 1:length(valid_gt)
            n_at = 0;
            for a = 1:length(objectattributes)
                if strfind(Dgt(i).annotation.object(valid_gt(j)).attributes,objectattributes{a})
                    n_at = n_at + 1;
                end
            end
            if n_at == length(objectattributes)
                valid_gt_at = [valid_gt_at, valid_gt(j)];
            end
        end
        valid_gt = valid_gt_at;
    end
        
    valid_d = LMobjectindex(Dd(i).annotation, objectname, 'exact');
    
    % Get polygons from ground truth -> bounding boxes
    Gt(i).boxes = LMobjectboundingbox(Dgt(i).annotation, valid_gt);
    Gt(i).det = zeros(1,length(valid_gt));
    Gt(i).valid_gt = valid_gt;
    
    % Get polygons detection
    Bd = LMobjectboundingbox(Dd(i).annotation, valid_d);
    Nd = size(Bd,1);
    BBd = [BBd; Bd];
    
    if Nd>0
        confidence = [confidence Dd(i).annotation.object(valid_d).confidence];
    end
    
    % store ids
    id_im_d = [id_im_d i*ones(1,size(Bd,1))];
    id_object_d = [id_object_d; valid_d];
    
    % update n_pos
    npos = npos + length(valid_gt);
end

% sort detections by decreasing confidence
[sc,si]=sort(confidence,'descend');
id_im_d = id_im_d(si);
id_object_d = id_object_d(si);
BBd = BBd(si,:);

% assign detections to ground truth objects
nd=size(BBd,1); % number of total detections
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;
for d = 1:nd
    
    % display progress
    if toc>1
        fprintf('%s: pr: compute: %d/%d\n',objectname,d,nd);
        drawnow;
        tic;
    end
    
    % find ground truth image
    i_image = id_im_d(d);
    
    % assign detection to ground truth object if any
    bb=BBd(d,:);
    ovmax=-inf;
    for j=1:length(Gt(i_image).det) % per each of the detections
        bbgt=Gt(i_image).boxes(j,:);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 && ih>0                
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
    end
    
    % assign detection as true positive/false positive and add
    % taggs
    if ovmax>=minoverlap        
        if ~Gt(i_image).det(jmax)
            tp(d)=1; % true positive
            Dd(id_im_d(d)).annotation.object(id_object_d(d)).detection = 'true';
            Gt(i_image).det(jmax)=true;            
        else
            fp(d)=1; % false positive (multiple detection)
            Dd(id_im_d(d)).annotation.object(id_object_d(d)).detection = 'false';
        end        
    else
        fp(d)=1; % false positive
        Dd(id_im_d(d)).annotation.object(id_object_d(d)).detection = 'false';
    end
end

% compute precision/recall
fp2=cumsum(fp);
tp2=cumsum(tp);
recall=tp2/npos;
precision=tp2./(fp2+tp2);

% compute AP
mrec=[0 ; recall ; 1];
mpre=[0 ; precision ; 0];
for i=numel(mpre)-1:-1:1
    mpre(i)=max(mpre(i),mpre(i+1));
end
i=find(mrec(2:end)~=mrec(1:end-1))+1;
averagePrecision=sum((mrec(i)-mrec(i-1)).*mpre(i));

% add missed true positives
for i = 1:NimagesGt
    Dd(i).annotation.filename = Dgt(i).annotation.filename;
    Dd(i).annotation.folder = Dgt(i).annotation.folder;
    for j = 1:length(Gt(i).valid_gt)        
        if ~Gt(i).det(j)
            Dd(i).annotation.object(end+1).name = Dgt(i).annotation.object(Gt(i).valid_gt(j)).name;
            Dd(i).annotation.object(end).deleted = Dgt(i).annotation.object(Gt(i).valid_gt(j)).deleted;
            Dd(i).annotation.object(end).date = Dgt(i).annotation.object(Gt(i).valid_gt(j)).date;
            Dd(i).annotation.object(end).id = Dgt(i).annotation.object(Gt(i).valid_gt(j)).id;
            Dd(i).annotation.object(end).polygon = Dgt(i).annotation.object(Gt(i).valid_gt(j)).polygon;
            Dd(i).annotation.object(end).detection = 'missed';
        end
    end
end

% plot precision/recall
if draw
    plot(recall,precision,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: %s, AP = %.3f',objectname,averagePrecision));
end

