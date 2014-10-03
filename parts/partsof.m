function D = partsof(D,name,parts,thresh)
% Finds the parts of an object and modifies the database structure D so
% that parts point to the object to which it belongs.  To find the parts
% of a "car", do the following:
%
% D = partsof(D,'car');
%
% If object j in image i is a part of a car, then
% D(i).annotation.object(j).partof will be set to the ID of the car to
% which it belongs in the image.

if nargin < 4
    thresh = 0.5;
end

[~,jj] = LMquery(D,'object.name',[name ',' parts]);

for ii = 1:length(jj)
    jo = LMobjectindex(D(jj(ii)).annotation,name);
    jp = LMobjectindex(D(jj(ii)).annotation,parts);
    M = zeros(length(jo),length(jp));
    for kk = 1:length(jo)
        for ll = 1:length(jp)
            M(kk,ll) = 0;
            [XXo,YYo] = getLMpolygon(D(jj(ii)).annotation.object(jo(kk)).polygon);
            [XXp,YYp] = getLMpolygon(D(jj(ii)).annotation.object(jp(ll)).polygon);

            ro = [min(XXo) min(YYo) max(XXo) max(YYo)];
            rp = [min(XXp) min(YYp) max(XXp) max(YYp)];

            if rect_intersect(ro,rp) >= thresh

                Ao = polyarea(XXo,YYo);
                Ap = polyarea(XXp,YYp);
                if Ao > Ap
                    M(kk,ll) = int_area(XXo,YYo,XXp,YYp)/Ap;
                end
            end
        end
    end
    [vals,inds] = max(M,[],1);
    
    %
    % 
    for kk = 1:length(inds)
        if vals(kk) >= thresh
            [ids,jj_id] = getID(D(jj(ii)).annotation);
            id_ind = find(jj_id==jo(inds(kk)));
            
            object_id = ids(id_ind);
            part_id = 
            D(jj(ii)).annotation = addpart_i_to_object_j(D(jj(ii)).annotation, ids(id_ind), j);
            
            if ~isempty(id_ind)
                D(jj(ii)).annotation.object(jp(kk)).partof = num2str(ids(id_ind));
            elseif ~isempty(ids)
                D(jj(ii)).annotation.object(jo(inds(kk))).id = num2str(max(ids)+1);
                D(jj(ii)).annotation.object(jp(kk)).partof = num2str(max(ids)+1);
            else
                D(jj(ii)).annotation.object(jo(inds(kk))).id = '0';
                D(jj(ii)).annotation.object(jp(kk)).partof = '0';
            end
            D(jj(ii)).annotation.object(jp(kk)).partofobject = ...
                D(jj(ii)).annotation.object(jo(inds(kk))).name;
        end
    end
end

function annotation = addpart_i_to_object_j(annotation,i,j)

annotation.object(j).parts.hasparts = i;
annotation.object(i).parts.ispartof = j;


function [v,j] = getID(annotation)

if isfield(annotation,'object') && isfield(annotation.object(1),'id')
    v = str2double({annotation.object(:).id});
    j = find(~isnan(v));
    v = v(j);
    if length(v) ~= length(unique(v))
        disp('WARNING: getID(): There are duplicate IDs!');
    end
else
    v = [];
    j = [];
end

function tt = rect_intersect(ro,rp)
% min_x,min_y,max_x,max_y

tt = 0;
wo = ro(3)-ro(1);
ho = ro(4)-ro(2);
wp = rp(3)-rp(1);
hp = rp(4)-rp(2);
if (wp*hp) > 0
    tt = rectint([ro(1) ro(2) wo ho],[rp(1) rp(2) wp hp]) / (wp*hp);
end
