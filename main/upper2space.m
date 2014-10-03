function s = upper2space(s)
% Finds capital letters and inserts a space 
% example: carSide => car Side

n = uint8(s(2:end));
j = find(n<=90 & n>=65)+1;

for n = 1:length(j)
    s = [s(1:j(n)-1) ' ' s(j(n):end)];
    j = j+1;
end

