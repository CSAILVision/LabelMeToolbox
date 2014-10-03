function tree = wordnetTree(varargin)
%
% tree = wordnetTree(D);
% 
% or
%
% tree = wordnetTree(sensesfile)


sensesfile = '';
if length(varargin) == 0
    sensesfile = 'wordnetsenses.txt';
else
    if ischar(varargin{1})
        % tree = wordnetTree(sensesfile)
        sensesfile = varargin{1};
    else
        error(' CODE NOT FINISHED ')
        % tree = wordnetTree(D);
        %keyboard
        D = varargin{1};
        [wordnet, counts] = findsenses(D);
    end
end


if length(sensesfile)>0
    % load senses
    if exist(sensesfile)
        fid = fopen(sensesfile);
        C= textscan(fid,'%s', 'delimiter', '\n');
        fclose(fid)
        C = C{1};
        %C = importdata(sensesfile);
        description = strtrim(C(1:4:end));
        synonims = C(2:4:end);
        synset = lower(C(3:4:end));
    else
        error('Senses file not found')
    end
end


% Extract unique senses and counts
[synset, i, j] = unique(synset);
synonims = synonims(i);
Nsenses = length(synset);
[counts, x] = hist(j, 1:Nsenses);

tree.parent = []; % node = 0 is the root node
tree.nodewords = {};
tree.counts = zeros(Nsenses*20,1);

for i = 1:Nsenses
    i
    if length(sensesfile)>0
        branch = [synonims{i}; strread(synset{i}, '%s', 'delimiter', '.')];
    else
        branch = strread(synset{i}, '%s', 'delimiter', '.');
    end

    [tree, nodes] = addbranch(tree, branch);
    for nd = 1:length(nodes)
        if nodes(nd)>length(tree.counts)
            tree.counts(nodes(nd)) = counts(i);
        else
            tree.counts(nodes(nd)) = tree.counts(nodes(nd))+counts(i);
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tree, nodes] = addbranch(tree, branch)
%
% Add a new branch to the tree

N = length(branch);
M = length(tree.parent);
parent = 0; %start on the root
for n = N:-1:1
    % two different nodes might have the same name!
    np = find(tree.parent==parent);
    node = strmatch(strtrim(branch{n}), tree.nodewords(np), 'exact');
    node = np(node);

    if length(node)==0
        % connect node to the root
        tree.parent(M+1) = parent;
        tree.nodewords{M+1} = strtrim(branch{n});
        nodes(n) = M+1;

        M = M+1;
        parent = M;
    else
        parent = node;
        nodes(n) = node;
    end
end


