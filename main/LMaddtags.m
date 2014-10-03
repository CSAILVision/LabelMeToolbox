function [D, unmatched] = LMaddtags(D, tagsfile, method)
%
% [D, unmatched] = LMaddtags(D, 'tags.txt', method);
%
% Reemplaces object names with the names in the list tags.txt
% The objects that are not matched are replaced by the label 'unmatched'
%
% The old labelme description will be stored in a new field: 
%  D.annotation.object.description
%
% method: specifies the replacements method'
%  'unmatched': it will add this tag is an object is not found (this is the
%  default)
%  'keepname': it will keep the old name for unmatched objects.
%  'create': it will create a new tags file by listing all the objects in
%      D. The file can be edited with a text editor in order to modify the
%      synonyms list

if nargin < 3
    method = 'unmatched';
end

counts_changes = 0;
counts_unmatched = 0;

if ~strcmp(method, 'create')
    [Tag, Descriptions] = loadtags(tagsfile);
    Ntags = length(Tag);
    
    % 1) Create list of labelme descriptions
    disp('finding object list')
    [labelmeDescriptions, counts, imagendx, objectndx, descriptionndx] = LMobjectnames(D);
    
    % 2) Find tag for each description and make list of unmatched descriptions
    ndxtag = zeros(length(labelmeDescriptions),1);
    for i = 1:length(labelmeDescriptions)
        for k = 1:Ntags
            j = strmatch(lower(labelmeDescriptions{i}), Descriptions{k}, 'exact');
            if ~isempty(j)
                ndxtag(i) = k;
                break
            end
        end
    end
    
    % Create list of unmatched descriptions and sort them by counts
    unmatched = labelmeDescriptions(ndxtag==0);
    [cc,jj]   = sort(counts(ndxtag==0), 'descend');
    unmatched = unmatched(jj);
    
    % 3) Add tag field to matched objects
    disp('add tags')
    for i = find(ndxtag>0)'
        j = find(descriptionndx==i);
        for k = 1:length(j)
            D(imagendx(j(k))).annotation.object(objectndx(j(k))).name = Tag{ndxtag(i)};
            counts_changes = counts_changes+1;
        end
    end
    
    % 4) Add unmatched tag for descriptions not matched
    if strcmp(method, 'unmatched')
        for i = find(ndxtag==0)'
            j = find(descriptionndx==i);
            for k = 1:length(j)
                D(imagendx(j(k))).annotation.object(objectndx(j(k))).name = 'unmatched';
                counts_unmatched = counts_unmatched+1;
            end
        end
    end
    
    % Visualization
    if nargout == 0
        [labelmetags, counttags] = LMobjectnames(D, 'tag');
        
        figure
        loglog(sort(counts, 'descend'), 'r')
        hold on
        loglog(sort(counttags(2:end), 'descend'), 'g')
        xlabel('rank')
        ylabel('counts')
        axis('tight')
        title(sprintf('descriptions: %d, Ntags:%d, polygons: %d, with tags: %d', length(labelmeDescriptions), Ntags, sum(counts), sum(counttags(2:end))))
    end
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CREATE NEW FILE
    disp('create list of common works')
    if exist(tagsfile, 'file')
        error('The file already exists. This operation creates a new file')
    else
        [names, counts] = LMobjectnames(D);
        j = find(counts>10);
        names = names(j);
        counts = counts(j);
        
        %[counts,j] = sort(counts, 'descend')
        [foo,j] = sort(names)
        names = names(j);

        
        fid = fopen(tagsfile, 'w');
        for n = 1:length(names)
            fprintf(fid, 'TAG: %s\n', names{n});
            fprintf(fid, 'lmd: %s\n', names{n});
        end
        fclose(fid)
        
    end
    
end


D = LMvalidobjects(D); % we need this because some object names might become empty if they had only stop words.

fprintf('Changed: %d out of %d \n', counts_changes, sum(counts))
if strcmp(method, 'unmatched')
    fprintf('Unmatched names: %d \n', counts_unmatched)
end

