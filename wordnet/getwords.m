function w=getwords(s)
% w=getwords(s)
%
% Returns a cell array with the individual words in the string 's'

s = upper2space(s);
w = strread(s, '%s', 'delimiter', '-_., ');
w = strrep(w, '(', '');
w = strrep(w, ')', '');
w = strrep(w, '''', '');
w = strrep(w, '"', '');
w = strrep(w, ';', '');
w = strrep(w, '&', '');
w = strrep(w, '?', '');
w = strrep(w, '!', '');




