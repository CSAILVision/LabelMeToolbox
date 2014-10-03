function [D, tree, found, descriptions] = addWordnet(D, treeInit);
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


% 1) get all the descriptions:
[descriptions, counts, imagendx, objectndx, descriptionndx] = LMobjectnames(D);
Ndescriptions = length(descriptions);
Nimages = length(D);

% 2) coocurrences counts
C = zeros(Nimages, Ndescriptions);
for i = 1:Ndescriptions
    j = imagendx(find(descriptionndx==i));
    C(j, i) = 1;
end
r = corrcoef(C);
r = r - diag(diag(r));

% 3) for all the descriptions, collect the branches
for i = 1:Ndescriptions
    disp(sprintf('%d (%d)', i, Ndescriptions));
    
    [senses(i).wordnet, found(i)] = getWordnetSense(descriptions{i});
end

% 4) for each word, look at the most frequent words that are associated to
% it and make them vote for senses.
for i = 1:Ndescriptions    
    R = r(i,:);
    [R,n] = sort(-R); R = -R;
    correlatedWords = n(find(R>.1));
    disp([sprintf('\n%d. =>   %s correlates with ', i, descriptions{i}) sprintf('%s, ', descriptions{n(correlatedWords)})]);


    Nsenses = length(correlatedWords)*10;
    
    % 2) get voting from tree
    %  2.1) build tree from correlated objects
    tree.parent = []; % node = 0 is the root node
    tree.nodewords = {};
    tree.scores = zeros(max(200,Nsenses*100),1);

    for n = correlatedWords
        % add branches to the tree
        Nwords = length(senses(n).wordnet);
        for w = 1:Nwords
            Nbranch = length(senses(n).wordnet(w).branch);
            freq = senses(n).wordnet(w).frequency/20 + 1;
            freq = freq'/sum(freq);
            for k = 1:Nbranch
                branch = {senses(n).wordnet(w).synonyms{k} senses(n).wordnet(w).branch{k}{:}};
                %disp(sprintf('branch %d', k))
                [tree, nodes] = addbranch(tree, branch);

                %Global votes. Each node has a score (number of times it is used)
                tree.scores(nodes) = tree.scores(nodes)+counts(i)*freq(k).^.5;
            end
        end
    end
    
    % 2.2) evaluate score.
    Nwords = length(senses(i).wordnet);
    for w = 1:Nwords
        Nbranch = length(senses(i).wordnet(w).branch);
        % get frequencies for each sense
        freq = senses(i).wordnet(w).frequency/20 + 1;
        freq = freq'/sum(freq);

        if Nbranch > 0
            % evaluate votes from tree
            Gscore = zeros(Nbranch,1);
            for k = 1:Nbranch
                branch = {senses(i).wordnet(w).synonyms{k} senses(i).wordnet(w).branch{k}{:}};
                %disp(sprintf('branch %d', k))
                nodes = findbranch(tree, branch);
                nodes = nodes(nodes>0);

                %Global votes. Each node has a score (number of times it is used)
                Gscore(k) = sum(tree.scores(nodes));
            end
            Gscore = Gscore/sum(Gscore+eps);

            [G, bs] = max(Gscore.*freq.^.5);
        else
            % if there is only one descrition, then just take most common
            % sense:
            [G, bs] = max(freq);
        end
        disp([sprintf('* %s most likely meaning is:', senses(i).wordnet(w).words) sprintf('%s, ', senses(i).wordnet(w).branch{bs}{:})]);

        % store selected branch
        senses(i).wordnet(w).bestbranch = bs;
    end
end

% 5) build full tree with all the possible interpretations
if nargin == 2
    tree = treeInit;
else
    tree.parent = []; % node = 0 is the root node
    tree.nodewords = {};
    tree.scores = zeros(max(200,Nsenses*100),1);
end
for i = 1:Ndescriptions
    Nwords = length(senses(i).wordnet);
    for w = 1:Nwords
        % add branches to the tree
        bs = senses(i).wordnet(w).bestbranch;
        branch = {senses(i).wordnet(w).synonyms{bs} senses(i).wordnet(w).branch{bs}{:}};
        [tree, nodes] = addbranch(tree, branch);
        for nd = 1:length(nodes)
            if nodes(nd)>length(tree.scores)
                tree.scores(nodes(nd)) = counts(i);
            else
                tree.scores(nodes(nd)) = tree.scores(nodes(nd))+counts(i);
            end
        end
    end
end


% 6) Add senses to the struct D
Nimages = length(D);
for n = 1:Nimages
    disp(sprintf('%d (%d)', n, Nimages));
    j = find(imagendx == n);
    obj = objectndx(j);
    des = descriptionndx(j);
    for i = 1:length(obj)
        Nwords = length(senses(des(i)).wordnet);

        name = D(n).annotation.object(i).name;
        newname = [name '. '];
        for w = 1:Nwords
            bs = senses(des(i)).wordnet(w).bestbranch;
            branch = {senses(des(i)).wordnet(w).synonyms{bs} senses(des(i)).wordnet(w).branch{bs}{:}};
            newname = [newname sprintf('%s. ', branch{:})];
        end

        D(n).annotation.object(i).name = newname;
    end
end


%
%
% % 2) build full tree with all the possible interpretations
% tree.parent = []; % node = 0 is the root node
% tree.nodewords = {};
% tree.scores = zeros(max(200,Ndescriptions*100),1);
% clear nodes % this will store all the possible meanings for each description
% for i = 1:Ndescriptions
%     disp(sprintf('%d (%d)', i, Ndescriptions));
%     
%     [word, found(i)] = getWordnetSense(descriptions{i});
%     for n = 1:length(word)
%         % add branches to the tree
%         Nbranch = length(word(n).branch);
%         for k = 1:Nbranch
%             branch = {word(n).synonyms{k} word(n).branch{k}{:}};
%             disp(sprintf('branch %d', k))
%             [tree, nodes{i}{n}{k}] = addbranch(tree, branch);
%             
%             %Global votes. Each node has a score (number of times it is used)
%             tree.scores(nodes{i}{n}{k}) = tree.scores(nodes{i}{n}{k})+counts(i);
%             
%             %showTree(tree)
%             %pause
%         end
%     end
% end
% 
% Nnodes = length(tree.nodewords);
% tree.scores = tree.scores(1:Nnodes);
% 
% % 3) select senses based on global/local votes. Each node has a score (number of times it is used)
% % Local votes: Select senses for each description on each image. This loops on the images, so that
% % we can take into account that a word might match to different meanings as
% % a function of context.
% %
% % This time the loop is done on the images.
% Nimages = length(D);
% branches = [];
% for n = 1:Nimages
%     n
%     j = find(imagendx == n);
%     % index for all the descriptions associated to this image
%     dc = descriptionndx(j);
%     % compute scores for each branch of the global tree using all the
%     % words/descriptions in the current image
%     local_scores = zeros(Nnodes,1);
%     % loop on descriptions
%     for i = 1:length(dc)
%         % loop on words per description
%         if dc(i)<=length(nodes)
%             if length(nodes{dc(i)})>0
%                 for w = 1:length(nodes{dc(i)})
%                     % loop on possible branches for each word in the description
%                     for k = 1:length(nodes{dc(i)}{w})
%                         local_scores(nodes{dc(i)}{w}{k}) = local_scores(nodes{dc(i)}{w}{k})+1;
%                     end
%                 end
%             end
%         end
%     end
% 
%     % evaluate score for each interpretation/word/description and select the one
%     % with the highest score
%     for i = 1:length(j)
%         if dc(i)<=length(nodes)
%             Nwords = length(nodes{dc(i)});
%             for w = 1:Nwords
%                 Nbranches = length(nodes{dc(i)}{w});
%                 if Nbranches>0
%                     % loop on possible branches for each description
%                     Lscore = zeros(Nbranches,1);
%                     Gscore = zeros(Nbranches,1);
%                     for k = 1:Nbranches
%                         Lscore(k) = sum(local_scores(nodes{dc(i)}{w}{k}));
%                         Gscore(k) = sum(tree.scores(nodes{dc(i)}{w}{k}));
%                     end
% 
%                     [s, b] = max(Lscore/max(Lscore)+2*Gscore/max(Gscore));
%                     %[s, b] = max(Gscore);
%                     branches(j(i)).words{w} =  tree.nodewords(nodes{dc(i)}{w}{b});
%                 end
%             end
%         end
%     end
% end
% 
% % 4) Add senses to the struct D
% Nimages = length(D);
% for n = 1:Nimages
%     disp(sprintf('%d (%d)', n, Nimages));
%     j = find(imagendx == n);
%     obj = objectndx(j);
%     for i = 1:length(obj)
%         Nwords = length(branches(j(i)).words);
%         
%         name = D(n).annotation.object(i).name;
%         newname = [name '. '];
%         for w = 1:Nwords
%             newname = [newname sprintf('%s. ', branches(j(i)).words{w}{:})];
%         end
% 
%         D(n).annotation.object(i).name = newname;
%     end
% end
% 
% 
% % 5) build final clean tree:
% tree.parent = []; % node = 0 is the root node
% tree.nodewords = {};
% tree.scores = zeros(Nnodes,1);
% Nbranch = length(branches);
% scores = zeros(Nnodes,1);
% for k = 1:Nbranch
%     Nwords = length(branches(k).words);
%     for w = 1:Nwords
%         [tree, nodes] = addbranch(tree, branches(k).words{w});
%         tree.scores(nodes) = tree.scores(nodes)+1;
%     end
% end
% 
% % 
% % figure
% % treeplot(tree.parent);
% % hold on
% % [x,y,h,s] = treelayout(tree.parent);
% % for n = 1:length(x)
% %     plot(x(n), y(n), 'o', 'markersize', 30*tree.scores(n)/max(tree.scores), 'MarkerFaceColor', 'g');    
% %     %plot(x(n), y(n), 'o', 'markersize', 1+30*local_scores(n)/max(local_scores), 'MarkerFaceColor', 'g');
% %     text(x(n), y(n), tree.nodewords{n});
% % end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tree, nodes] = addbranch(tree, branch)
% add a new branch to the tree

N = length(branch);
M = length(tree.parent);
parent = 0; %start on the root
for n = N:-1:1
    % two different nodes might have the same name!
    np = find(tree.parent==parent);
    node = strmatch(strtrim(branch{n}), tree.nodewords(np), 'exact'); 
    node = np(node); 
    
    if length(node)==0
        %disp(['.' branch{n} '.'])
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

function nodes = findbranch(tree, branch)
% returns a vector of indices pointing to the nodes
% length(nodes) = length(branch)


N = length(branch);
M = length(tree.parent);
parent = 0; %start on the root
for n = 1:N
    node = strmatch(branch{n}, tree.nodewords, 'exact');
    if length(node)==0
        nodes(n) = -1;
    else
        nodes(n) = node(1);
    end
end









% 
% 
% Nimages = length(D);
% wordnet = zeros(Nimages,1);
% 
% for i = 1:Nimages
%     disp(sprintf('%d [%d]', i, Nimages))
%     if isfield(D(i).annotation, 'object')
%         for j = 1:length(D(i).annotation.object)
%             if isfield(D(i).annotation.object(j), 'name')
%                 name = D(i).annotation.object(j).name;
%                 
%                 word = getWordnetSense(name);
%                 wordnet(i) = length(word)>0;
% 
%                 newname = [name '. '];
%                 for n = 1:length(word)
%                     newname = [newname sprintf('%s. %s', word(n).synonyms, word(n).sense)];
%                 end
%                 
%                 D(i).annotation.object(j).name = newname;
%                 
%                 if nargout == 3
%                     % create tree structure
%                     % see what is the matlab format for trees so that we
%                     % can use their plot
%                     
%                     
%                 end
%             end
%         end
%     end
% end
% 
% % build the wordnet tree
% tree.edges
% tree.nodeword
% 
% % objects in each branch are queried by queriing all the nodes in the
% % branch (not just the leaves)
% 
% % plotTree -> creates an html page with the words connected to the query
% % tool
% 
% % ALTERNATIVE;
% % 1) collect all descriptions
% % 2) do unique to remove repetitions (but keep counts)
% % 3) build wordnet tree using all the senses from the labelme descriptions.
% % 4) for each labelme description, assign the sense that is used more often
% % (that shares more nodes with other descriptions in the same image and
% % across images). 
% %
% % for instance, if mouse and keyboard coocur in the same image, then both
% % share the sense: electronic device. This will remove the animal
% % interpretation.
% % Then, when an object appears alone, or when none of the sense shared nodes with other descriptions in the same image, we will take the sense most
% % frequently assigned to this word.
% %
% % http://www.up.univ-mrs.fr/veronis/pdf/1998wsd.pdf#search=%22wordnet%20sen
% % se%20disambiguation%22
% %
% %Some of the earliest attempts to exploit WordNet for sense disambiguation are in the
% %field of information retrieval. Using the hyponomy links for nouns in
% %WordNet, Voorhees
% %(1993) defines a construct called a hood in order to represent sense categories, much as
% %Roget's categories are used in the methods outlined above. A hood for a given word w is
% %defined as the largest connected subgraph that contains w. For each content word in a
% %document collection, Voorhees computes the number of times each synset appears above
% %that word in the WordNet noun hierarchy, which gives a measure of the expected activity
% %(global counts); she then performs the same computation for words occurring in a particular
% %document or query (local counts). The sense corresponding to the hood root for which the
% %difference between the global and local counts is the greatest is chosen for that word. Her
% %results, however, indicate that her technique is not a reliable method for distinguishing
% %WordNet's fine-grained sense distinctions.
% 
% 
% 
% 
% 
