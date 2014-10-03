function id = getLMobjectID(annotation, n)
%

if isfield(annotation, 'object')
    if isfield(annotation.object(n), 'id')
        id = annotation.object(n).id;
    else
        id = n;
    end
else
    id = 0;
end
