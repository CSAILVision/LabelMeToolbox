function [j, dist] = LMhistintersectionquery(Query, h)
%
% Assumes histograms are normalized and sum = 1

N = size(h,1);

dist = 1-sum(min(h, repmat(Query, [N 1])),2); % histogram intersection
[dist, j] = sort(dist);

