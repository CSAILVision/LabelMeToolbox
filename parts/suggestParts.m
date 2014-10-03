function [suggestedParts, param] = suggestParts(D, objectname, param)

if nargin == 3
    Ppart = param.Ppart;
    objectClasses = param.objectClasses;
else
    [Ppart, objectClasses] = partsGraph(D);
    param.Ppart = Ppart;
    param.objectClasses = objectClasses;
end


j = strmatch(objectname, objectClasses, 'exact');


P = Ppart(j, :);
[p, jp] = sort(P, 'descend');


n = find(p>.2);
for i = 1:length(n)
    fprintf ('%s, ', objectClasses{jp(i)})
end

suggestedParts = objectClasses(n);
