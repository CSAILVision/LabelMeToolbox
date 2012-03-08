function name = removestopwords(name, stopwords)
% remove stop of words. The returned sequence is also parsed into words:
%
% removestopwords('carFrontal')
% ans = 
%   'car'
%
% You can also pass a cell array of strings with a list of words to be
% removed.
%
% If called without input arguments, it returs a cell array with the list
% of stopwords given by default. 
%
% stopwords = removestopwords;
%
% You can change the list of stopwords by modifiying the file
% stopwords.txt.  (one stopword per line).
%
% Also, this function can be used to remove the stopwords from the LabelMe
% index. This might remove also useful information. For instance, the words
% 'blue', 'frontal', ... will disapear.
%
% D = removestopwords(D)
%

if nargin < 2
    % load list of stop words
    fid = fopen('stopwords.txt');
    C = textscan(fid,'%s');
    fclose(fid);
    stopwords = C{1};
end

if nargin > 0
    if isstruct(name)
        for i = 1:length(name)
            if isfield(name(i).annotation, 'object')
                N = length(name(i).annotation.object);
                for j = 1:N
                    nameobj = name(i).annotation.object(j).name;

                    % we avoid recursive call for speed.
                    w = lower(getwords(nameobj));
                    k = ismember(w, stopwords);
                    w = w(~k);
                    nameobj = strtrim(sprintf('%s ', w{:}));

                    name(i).annotation.object(j).name = nameobj;
                end
            end
        end
    else
        w = lower(getwords(name));
        j = ismember(w, stopwords);
        w = w(~j);
        name = strtrim(sprintf('%s ', w{:}));
    end
else
    name = stopwords;
end



