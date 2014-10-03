function [v, tree] = xmlparse(xml)
%
% Translate an xml string into a matlab struct
%
% xml = '<a><b>1</b><b>3</b><b>4</b><c>4</c></a>'
% xml = '<a><b><d>1</d></b><b><d>2</d></b><b><c>3</c><e>5</e><e>6</e></b><d>1</d><b><c>4</c></b></a>'
% 
% [v, tree] = xmlparse(xml)
%

% This function replaces xml2struct.m to add more flexibility.
% Written by Antonio Torralba, June 2013

%keyboard

% xml 2 tree
tree = xml2tree(xml);

% tree 2 struct
v = tree2struct(tree, 0);



function v = tree2struct(tree, node)

v = [];
children = find(tree.parent==node);

if isempty(children)
    return
end

tag = tree.tagname(children);
values = tree.value(children);

for n = 1:length(tag)
    tagn = tag{n};
    valn = values{n};
    
    m=1;
    if n>1 && isfield(v, tagn)
        %m = 2;
        %if iscell(v.(tagn))
            m = 1+length(v.(tagn));
        %end
    end
    
    if ~isempty(valn)
        %if m == 2 && ~iscell(v.(tagn)) % the first element, in an array should be transformed to cell.
        %    tmp = v.(tagn);
        %    v.(tagn) = '';
        %    v.(tagn){1} = tmp;
        %end
        
        if m>1
            v.(tagn){m} = valn;
        else
            v.(tagn) = valn;
        end
    else
        tmp = tree2struct(tree, children(n));
        if ~isempty(tmp)
            if m==1
                v.(tagn) = tmp;
            else
                f = fieldnames(tmp);
                ff = ~isfield(v.(tagn), f);
                for mm = 1:length(f)
                    if ff(mm) %~isfield(v.(tagn),f{mm})
                        v.(tagn)(1).(f{mm}) = [];
                    end
                    v.(tagn)(m).(f{mm}) = tmp.(f{mm});
                end
            end
        end
    end
end



function tree = xml2tree(xml)

% First replace entries <tag/> by <tag></>
xml = strrep(xml, '/>', '></>');
xml = strrep(xml, '@', '_');
xml = strrep(xml, '#', '_');
xml = regexprep(xml, '>(\s*)<', '><'); % remove spaces between fields.

%keyboard
% split XML
pxml = strrep(xml, '</', '$#');  % #=-
pxml = strrep(pxml, '<', '$@');  % @=+
pxml = strrep(pxml, '>', '$');
pxml = strrep(pxml, '$$', '$');

elements = regexp(pxml, '[$]', 'split');
elements = elements(~cellfun('isempty',elements));

N = sum(pxml=='@');
tree.parent = zeros(N,1);
tree.tagname = cell(N,1);
tree.value = cell(N,1);

% Loop and get tags. An open tag goes up in the struct level, and closing
% tag goes down.
currentnode = 0;
n = 0;
for i = 1:length(elements)
    e = elements{i};
    e1 = e(1);
    
    if e1=='@'
        n = n+1;
        tree.parent(n) = currentnode;
        tree.tagname{n} = e(2:end);
        currentnode = n;
        
    elseif e1=='#'
        currentnode = tree.parent(currentnode);
        
    else
        tree.value{n} = strtrim(e);
    end
end


