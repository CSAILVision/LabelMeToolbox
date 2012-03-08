function gist = normalizeGist(gist)
%
% make vectors unit norm

[Ngists, Nfeatures] = size(gist);
gist = gist./repmat(sqrt(sum(gist.^2,2)), [1 Nfeatures]);

