function [counts, countrootwithparts, countparts] = LMcountparts(D, objectname, method)
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
countrootwithparts = zeros(n,1);
countparts = zeros(n,1);


for i = 1:length(D);
    counts(j(i)) = LMcountobject(D(i));
    countrootwithparts(j(i)) = 0;
    countparts(j(i)) = 0;
    for k = 1:LMcountobject(D(i))
        if isfield(D(i).annotation.object(k),'parts')
            if isfield(D(i).annotation.object(k).parts,'ispartof') && ~isempty(D(i).annotation.object(k).parts.ispartof)
                countparts(j(i)) = countparts(j(i))+1;
            elseif isfield(D(i).annotation.object(k).parts,'hasparts') && ~isempty(D(i).annotation.object(k).parts.hasparts)
                countrootwithparts(j(i)) = countrootwithparts(j(i))+1;
            end
        end
    end
end
    