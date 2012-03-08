function [Tag, Descriptions] = loadtags(tagsfile);
%
% [Tag, Descriptions] = loadtags('tags.txt');
%
% [D, unmatched] = LMaddtags(D, 'tags.txt');


fid = fopen(tagsfile);
C= textscan(fid,'%s', 'delimiter', '\n');
fclose(fid)
C = C{1};

Nlines = length(C);

j_tag = strmatch('TAG:', C);

Ntags = length(j_tag);

Tag = strrep(C(j_tag), 'TAG: ', '');


j_tag = [j_tag; Nlines];
for i = 1:Ntags
    tmp = C(j_tag(i):j_tag(i+1));
    j_lmd = strmatch('lmd:', tmp);
    Descriptions{i} = strrep(tmp(j_lmd), 'lmd: ', '');
end




