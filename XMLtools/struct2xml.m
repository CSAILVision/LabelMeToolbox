function xml = struct2xml(v)
%
% Transforms a struct or struct array into an XML string
%
% v = struct variable containing fields of type char or numeric
%

xml = [];

% New line character:
nl = char(13);
% Use nl = '' to remove new line characters.
nl = '';


names = fieldnames(v);
for n = 1:length(names)
    a = getfield(v, names{n});

    if isstruct(a)
        % If it is a struct, recursive call
        Nitems = length(a);
        % loop if it is a struct array
        for i = 1:Nitems
            xml = [xml '<' names{n} '>' nl struct2xml(a(i)) '</' names{n} '>' nl];
        end
    else
        % write field contents:
        if iscell(a); Nitems = length(a); else Nitems=1; a={a};end
        
        for i = 1:Nitems
            xml = [xml '<' names{n} '>' nl];
            if ischar(a{i})
                xml = [xml strtrim(a{i}) nl];
            else
                xml = [xml num2str(a{i}') nl];
            end
            xml = [xml '</' names{n} '>' nl];
        end
    end
end


