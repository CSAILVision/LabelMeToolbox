function [jtraining, jtest, jvalidation] = splitTrainingTest(class, ptrain, ptest, pval)
%
%[jtraining, jtest] = splitTrainingTest(class, [500 30 30], [500 30 30]);

c = unique(class);
Nclasses = length(c);

jtraining = [];
jtest = [];
jvalidation = [];

if length(ptrain)==1
    ptrain = ptrain*ones([1 Nclasses]);
end
if length(ptest)==1
    ptest = ptest*ones([1 Nclasses]);
end

for n = 1:Nclasses
    j = find(class == c(n));
    N = length(j);
    
    if N>2;
        r = randperm(N);
        j = j(r);
        
        
        if ptrain<1
        else
            ptr = min(ptrain(n), max(1,fix(N-2)));
            
            jtraining = [jtraining j(1:ptr)];
            if nargin < 3
                jtest = [jtest j(ptr+1:end)];
            else
                pte = min(ptest(n), N-ptr);
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


