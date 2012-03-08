function [D, tree, found] = addWordnetFolders(D);
% 
% Adds to the object names, synonyms from wordnet.
% Uses is a simple algorithm for sense desambiguation.
%
% Dw = addWordnet(D);
% LMdbshowobjects(LMquery(Dw, 'object.name', 'animal', 'word'), HOMEIMAGES)
%
% You need to install wordnet: http://wordnet.princeton.edu/

% addwordnet3
% 0) get word frequencies in getWordnetSense
% 1) get all words an compute co-ocurrences between words
% 2) for each word select sense common with co-ocurrent words (exclude from
% tree the current word!)

tree.parent = []; % node = 0 is the root node
tree.nodewords = {};
tree.scores = [];

found = [];
clear folders;
for i = 1:length(D)
    folders{i} = D(i).annotation.folder;
end
folders = unique(folders);
for n = 1:length(folders)
    disp(sprintf('Folder %d (out of %d)', n, length(folders)))
    
    [Dq, q]    = LMquery(D, 'folder', folders{n});
    if length(q)>3
        [Dq, tree, f,des] = addWordnet(Dq, tree);
        D(q) = Dq;
        found(q) = f;
 
        disp(sprintf('   there are %d descriptions, and we found senses for %d.', length(des), sum(found)))
        Nnodes = length(tree.parent);
        leaves = setdiff(1:Nnodes, tree.parent); % these are all the nodes without parents
        disp(sprintf('   there are %d leaves, and there are %d objects with senses.', length(leaves), sum(tree.scores(leaves))))
    end
end


