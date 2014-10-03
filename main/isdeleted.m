function b = isdeleted(annotation)
% returns  b=1  if deleted

Nobj = length(annotation.object);
b = zeros(Nobj,1);
for i = 1:Nobj
    if ~isfield(annotation.object(i), 'deleted')
        b(i)=0;
    else
        if isempty(annotation.object(i).deleted)
            b(i)=0;
        else
            if ischar(annotation.object(i).deleted)
                b(i) = strcmp('1', annotation.object(i).deleted);
            else
                b(i) = annotation.object(i).deleted==1;
            end
        end
    end
end
