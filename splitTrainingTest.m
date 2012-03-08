function [jtraining, jtest, jvalidation] = splitTrainingTest(class, ptrain, ptest, pval)

c = unique(class);
Nclasses = length(c);

jtraining = [];
jtest = [];
jvalidation = [];


for n = 1:Nclasses
    j = find(class == c(n));
    N = length(j);
    
    if N>2;
        r = randperm(N);
        j = j(r);
        
        
        if ptrain<1
        else
            ptr = min(ptrain, max(1,fix(N-2)));
            
            jtraining = [jtraining j(1:ptr)];
            if nargin < 3
                jtest = [jtest j(ptr+1:end)];
            else
                pte = min(ptest, N-ptr);
                jtest = [jtest j(ptr+1:ptr+pte)];
                if nargin == 4
                    jvalidation = [jvalidation j(ptr+pte+1:ptr+pte+pval)];
                end
            end
        end
    else
        disp(sprintf('class %d has fewer than 2 examples', c(n)))
    end
end


