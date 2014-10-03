function counts = LMcountobject(D, objectname, method)
% Returns the number of object instances of the class 'objectname' for each
% entry in the database.
%
% Example: to know how many side views of cars there are in every image:
% counts = LMcountobject(D, 'car+side');
%

if nargin == 2;
    method = '';
end

n = length(D);

if nargin == 2
    [D, j] = LMquery(D, 'object.name', objectname, method);
else
    j = 1:n;
end

counts = zeros(n,1);

for i = 1:length(D);
    if isfield(D(i).annotation,'object')
        counts(j(i)) = sum(isdeleted(D(i).annotation)==0);
        %counts(j(i)) = length(D(i).annotation.object);
    end
end
