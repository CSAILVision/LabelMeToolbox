function [D, unmatched, counts] = LMaddwordnet(D, sensesfile, method)
%
% [D, unmatched, counts] = LMaddwordnet(D, sensesfile, method)
%
% Adds synsets to object names. It adds the 'synset' field to
% the 'object' field.
% 
% sensesfile: name of the text file that contains the synonyms list.
% 
% Methods:
%  'concatenate' [default]: concatenates to object name the synset
%  'samename': does not modify the field 'name'. 
%  'synset': replaces the field 'name' with the synset
%
% This tool uses synsets provided by:
% WordNet 2.1 Copyright 2005 by Princeton University.
% http://wordnet.princeton.edu/

% load wordnet file. 
if nargin < 2
    sensesfile = 'wordnetsenses.txt';
end
if nargin < 3
    method = 'concatenate';
end

% load list of stop words
stopwords = removestopwords;

% load senses
if exist(sensesfile)
    fid = fopen(sensesfile);
    C= textscan(fid,'%s', 'delimiter', '\n');
    fclose(fid)
    C = C{1};
    %C = importdata(sensesfile);
    description = strtrim(C(1:4:end));
    synonims = C(2:4:end);    
    synset = C(3:4:end);
end

Nimages = length(D);

% Take labelme description and split it into words
unmatched = []; u = 0;
for i = 1:Nimages
    i
    if isfield(D(i).annotation, 'object')
        N = length(D(i).annotation.object);

        for j = 1:N
            name = D(i).annotation.object(j).name;

            ndx = findsynset(name, description, stopwords);
            if length(ndx)>0
                ndx = ndx(1);
                switch method
                    case 'concatenate'
                        wordnetname = [name '. ' synonims{ndx} '. ' synset{ndx}];
                    case 'synset'
                        % replaces the current name with the wordnet synset
                        wordnetname = [synonims{ndx} '. ' synset{ndx}];
                    otherwise
                        % default (
                        wordnetname = name;
                end
                D(i).annotation.object(j).synset = [synonims{ndx} '. ' synset{ndx}];
            else
                u = u+1;
                unmatched{u} = removestopwords(name, stopwords);
                wordnetname = name;
            end

            wordnetname = strrep(wordnetname, ',', '+');
            wordnetname = strrep(wordnetname, '.', '+');
            wordnetname = strrep(wordnetname, '-', '+');
            wordnetname = strrep(wordnetname, ' ', '+');
            wordnetname = strrep(wordnetname, '++', '+');
            wordnetname = strrep(wordnetname, '+', ' ');
            wordnetname = getwords(wordnetname);
            [foo, si] = unique(wordnetname);
            wordnetname = wordnetname(sort(si));
            wordnetname = strtrim(lower(sprintf('%s ', wordnetname{:})));

            D(i).annotation.object(j).name = wordnetname;
        end
    end
end

% sort unmatched descriptions by counts:
[unmatched, i, ndx] = unique(strtrim(lower(unmatched)));
Nobject = length(unmatched);
[counts, x] = hist(ndx, 1:Nobject);
[counts, j] = sort(-counts); counts = - counts;
unmatched = unmatched(j);




function j = findsynset(name, descriptions, stopwords)

name = removestopwords(name, stopwords);
j = strmatch(name, descriptions, 'exact');
