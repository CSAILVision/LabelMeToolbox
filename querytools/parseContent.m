function query = parseContent(content, character)
% Utility function.
%
% Parses the query string and produce a cell array of cell arrays.
% This function is called from several functions in the toolbox.
%
% It is case sensitive.
%

if nargin == 1
    character = ',';
end

query = {};
ndx = [0 findstr(content, character) length(content)+1];
n=0;
for nn=1:length(ndx)-1
    element = content(ndx(nn)+1:ndx(nn+1)-1);
    if ~isempty(element)
        n = n+1;
        if element(1)~='+' & element(1)~='-'
            element = ['+' element];
        end
        
        %clear term;
        ndxQ = sort([findstr(element, '+') findstr(element, '-') length(element)+1]);
        for m=1:length(ndxQ)-1
            if element(ndxQ(m))
                %term{m} = lower(element(ndxQ(m):ndxQ(m+1)-1));
                %term{m} = element(ndxQ(m):ndxQ(m+1)-1);
                query{n}{m} = element(ndxQ(m):ndxQ(m+1)-1);
            end
            %query{n} = term;
        end
    end
end

