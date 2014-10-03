function [objectPartStatistics] = LMpartstatistics(D,object_name)

% Returns the following structure:
%     objectPartStatistics(i).object_name: name of object
%     objectPartStatistics(i).object_count: number of instances in D of this object
%     objectPartStatistics(i).parts: all the parts combination of the object
%             objectPartStatistics(i).parts(j).part_names: list of parts combination 
%             objectPartStatistics(i).parts(j).count: number of instances that have the j-th parts combination
%  
%  If the number of arguments is 2 it just lists the parts combination for the specified object. 
%  Otherwise it returns the parts combination for all the objects.
%
%  Both objects and parts combination are sorted in descendent order
%  according to the number of instances available

if nargin == 2
    D = LMquery(D,'object.name',object_name);
end

[ob_names ob_count] = LMobjectnames(D);
[ob_count ind] = sort(ob_count,'descend');
ob_names2 = ob_names;
for i = 1:length(ob_names)
    ob_names{i} = ob_names2{ind(i)};
end
clear ob_names2
part_names = LMpartnames(D);
% part_names = setdiff(part_names,ob_names);

Nobjects = sum(ob_count);
for ob = 1:length(ob_names)
    fprintf('%d/%d\n',ob,length(ob_names));
    objectPartStatistics(ob).object_name = ob_names{ob};
    objectPartStatistics(ob).object_count = ob_count(ob);
    M = zeros(Nobjects,length(part_names));
    k = 0;
    for i = 1:length(D)
        for j = 1:LMcountobject(D(i))
            if strcmp(D(i).annotation.object(j).name,ob_names{ob}) % we should eliminate duplicate spaces, or spaces at the end or at the beginning
                k = k + 1;
                if isfield(D(i).annotation.object(j),'parts')
                    if isfield(D(i).annotation.object(j).parts,'hasparts')
                        list = str2num(D(i).annotation.object(j).parts.hasparts);
                        for n = 1:length(list)
                            [aux ind] = ismember(strtrim(lower({D(i).annotation.object(j).parts.object(:).name})),part_names);
                            M(k,ind) = 1;
                        end
                    end
                end
            end
        end
    end
    M = M(1:k,:);
    Comb = unique(M,'rows');
    fComb = zeros(1,size(Comb,1));
    for i =1:size(Comb,1)
        for m = 1:size(M,1)
            if sum(Comb(i,:) == M(m,:)) == size(Comb,2)
                fComb(i) = fComb(i) + 1;
            end
        end
    end
    objectPartStatistics(ob).object_count = k;
    parts_comb = [];
    [fComb ind] = sort(fComb,'descend');
    for k = 1:length(fComb)      
        parts_comb = find(Comb(ind(k),:) == 1);
        if isempty(parts_comb)
            objectPartStatistics(ob).parts(k).part_names = [];
        else
            for t = 1:length(parts_comb)
                objectPartStatistics(ob).parts(k).part_names{t} = part_names{parts_comb(t)};
            end
        end
         objectPartStatistics(ob).parts(k).count = fComb(k);
    end
end

if nargout == 0
    for ob = 1:length(ob_names)
        disp('-------------------------------------------')
        disp(sprintf('%d. %s (%d instances)', ob, ob_names{ob}, objectPartStatistics(ob).object_count));
        disp('-------------------------------------------')
        disp(sprintf(' Index|\t Counts\t|Name'));
        
        for i = 1:length(objectPartStatistics(ob).parts)
            cadena = sprintf('%5d |\t%7d\t|',i, objectPartStatistics(ob).parts(i).count);
            for k = 1:length(objectPartStatistics(ob).parts(i).part_names)
                cadena = strcat(cadena,sprintf(' %s ;',objectPartStatistics(ob).parts(i).part_names{k}));
            end
            disp(cadena);
        end
    end
    disp(sprintf('\n\n'));
end







   