function [word, found] = getWordnetSense(name)
% returns:
%        word(n).sense    = hierarchy{1};
%        word(n).synonyms = synonyms{1};
%        word(n).words    = words;
%
% This function is Matlab wraper that calls wordnet.
%
% You need to install wordnet: http://wordnet.princeton.edu/

% this is a list of words that should be ignored. They are common.
% stopwords = {'head', 'shoes', 'gray', 'red', 'blue', 'white', 'side', 'frontal', 'part', 'behind', 'crop', 'rear', 'back', 'front', 'left', 'right', 'occluded', 'the', 'in', 'a', 'view', 'big', 'whole', 'partial', 'poster'};

fid = fopen('stopwords.txt');
C = textscan(fid,'%s');
fclose(fid);
stopwords = C{1};


% Take labelme description and split it into words
w = getwords(name);

% remove common words
j = ismember(lower(w), stopwords);
w = w(~j);

Nwords = length(w);

init = 1;
last = Nwords;
word = [];

if length(w)>0
    n = 0;
    while 1
        words = sprintf('%s_', w{init:last}); words = words(1:end-1);
        [hierarchy, synonyms, h, found, frequency] = wordnet(words);
        if length(hierarchy) > 0
            n = n+1;
            word(n).branch   = h;
            word(n).sense    = hierarchy;
            word(n).synonyms = synonyms;
            word(n).words    = words;            
            word(n).frequency= frequency;
        end
        
        if last > init
            last = last - 1;
        else
            init = init+1;
            last = Nwords;
        end

        if init > Nwords
            break
        end
    end

    Nsenses = length(word);
    % remove repetitions (e.g., 'person woman' == 'woman'. Allways take the definition that is more specific)
    remove = [];
    %keyboard
    for i = 1:Nsenses
        for j = 1:Nsenses
            if ~ismember(i, remove) & ~ismember(j, remove)
                m = strfind(word(i).sense{1}, word(j).sense{1}); % j is in i?
                if length(m)>0 & i~=j
                    remove = [remove j];
                end
            end
        end
    end
    word = word(setdiff(1:Nsenses, remove));
end

if length(word)>0
    found = 1;
else
    found = 0;
end

function [hierarchy, synonyms, h, found, frequency] = wordnet(w)

removeINSTANCEOF = 1;
removeNOUMS = 1; % remove sense if the synonyms list starts with capital letters.

% Get all senses from wordnet
cmd = sprintf('!wn %s -hypen', w);
out_str = evalc(cmd);

% Get use frequency
cmd = sprintf('!wn %s -over', w);
out_str_over = evalc(cmd);

if (removeINSTANCEOF==0)
    out_str = strrep(out_str, 'INSTANCE OF', '');
end

if length(out_str>0)
    found = 1;
    % Put senses in cell array
    j = findstr(out_str, 'Sense');
    j = [j length(out_str)];
    clear sense hierarchy synonyms
    sense = [];
    for i = 1:length(j)-1
        sense{i} = out_str(j(i)+8:j(i+1)-1);
    end
    
    Nsenses = length(sense);

    % parse frequencies
    freq = zeros(Nsenses,1);
    for i = 1:Nsenses
        jj = findstr(out_str_over, sprintf('%d. ', i));
        if length(jj)>0
            jj = jj(1);
            chain = out_str_over(jj:jj+12);
            x1 = findstr(chain, '(');
            x2 = findstr(chain, ')');
            if length(x1)>0 & length(x2)>0
                freq(i) = str2num(chain(x1+1:x2-1));
            else
                freq(i) = 0;
            end
        end
    end

    %if (removeINSTANCEOF==0 | length(strfind(sense{m}, 'INSTANCE OF'))==0)
    %end
    
    frequency = [];
    mm = 0;
    for m = 1:Nsenses
        if (removeINSTANCEOF==0 | length(strfind(sense{m}, 'INSTANCE OF'))==0) 

            %keyboard
            % For each sense, extract the lines and get the hierarchy
            lin = strrep(sense{m}, ' ', '.');
            lin = strrep(lin, sprintf('\n'), '@');
            lines = strrep(strread(lin, '%s', 'delimiter', '@'), '.', ' ');

            %lines = strrep(strread(strrep(sense{m}, ' ', '.'), '%s', 'delimiter', '\n'), '.', ' ');
            % remove empty lines:
            v = [];
            for k = 1:length(lines)
                if length(strtrim(lines{k}))>0
                    v = [v k];
                end
            end
            lines = lines(v);
            syn = strtrim(lines{1});

            if removeNOUMS==0 | strcmp(syn(1), lower(syn(1)))

                mm = mm+1;
                
                frequency(mm) = freq(m);
                synonyms{mm} = strtrim(lines{1});
                j = strfind(lines(2:end), '=>'); j = [j{:}];
                lines = lines(1:length(j)+1); % remove the lines that do not contain => (assumes they are consecutive)

                % If a brach seems to break, let's take just the first one. Sure, we will
                % pay a price for this sin later.
                jj = find(j(2:end)-j(1:end-1)<0);
                if length(jj)>0
                    lines = lines(1:jj+1);
                end

                % Put the hierarchy separating levels with a dot.
                h{mm} = strtrim(strrep(lines, '=>', ''));
                v = [];
                for k = 1:length(h{mm})
                    if length(h{mm}{k})>0
                        v = [v k];
                    end
                end
                h{mm} = h{mm}(v);
                
                hierarchy{mm} = sprintf('%s. ', h{mm}{:});
            end
        end
    end

    if mm>0
        % Remove repetitions
        [hierarchy, j] = removeRepetitions(hierarchy);
        synonyms = synonyms(j);
        frequency = frequency(j);
        h = h(j);
    else
        hierarchy = '';
        synonyms = '';
        h = '';
        found = 0;
        frequency = 0;
    end
else
    hierarchy = '';
    synonyms = '';
    h = '';
    found = 0;
    frequency = 0;
end

% solve for parts.
% remove words without senses.
% use part hierarchy: the name valid is allways the part name



function [s,j] = removeRepetitions(s)
% s is a cell array of strings
%
% s = s(j);

N = length(s);

remove = [];
for i = 1:N
    for j = i:N
        m = strfind(s{i}, s{j}); % j is in i?
        if length(m)>0 & i~=j
            remove = [remove j];
        end
    end
end
j = setdiff(1:N, remove);
s = s(j);

