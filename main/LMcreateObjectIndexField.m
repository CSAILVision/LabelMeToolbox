function [D, names, counts] = LMcreateObjectIndexField(D)
%
% [D, names] = LMcreateObjectIndexField(D);
%
% This function adds a new field to the LabelMe index that provides a
% numeric index into the object class. 
% 
% The new field is:
%    annotation.object.namendx
% and this is a pointer into 'names'

% Create list of objects:
[names, counts, imagendx, objectndx, objclass_ndx] = LMobjectnames(D, 'name');
% add new field
for k = 1:length(objclass_ndx)
    D(imagendx(k)).annotation.object(objectndx(k)).namendx = objclass_ndx(k);
end


