function [j, dist] = LMgistquery(gistQuery, gist)

if 1
    % normalize correlation
    gistQuery = normalizeGist(gistQuery);
    gist = normalizeGist(gist);
    dist = 2-2*gist*gistQuery';
    [dist,j] = sort(dist);
else
    % L2
    dist = sum((gist - repmat(gistQuery, [size(gist,1) 1])).^2,2);
    [dist,j] = sort(dist);
end


