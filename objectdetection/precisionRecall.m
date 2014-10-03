function [recall, precision, th, averagePrecision] = precisionRecall(confidence, testClass, col)
% Plot precision-recall curve
%    [recall, precision, th, averagePrecision] = precisionRecall(confidence, testClass, col)
%
% Input
%    confidence: score of the classifier
%    testclass:  1 = inlier, 0 = outlier
%    col: color (it will make a plot)
%
% Output:
%    recall
%    precision
%    th: threhold needed for each point in the precision-recall curve
%    area: area of the precision-recall curve
%
% Definition of precision-recall:
% Assuming that:
%    * RET is the set of all items the system has retrieved for a specific inquiry;
%    * REL is the set of relevant items for a specific inquiry;
%    * RETREL is the set of the retrieved relevant items, i.e. RETREL = RET REL. 
% then precision and recall measures are obtained as follows:
%    precision = RETREL / RET
%    recall = RETREL / REL 

confidence = double(confidence);

S = rand('state');
rand('state',0);
confidence = confidence + rand(size(confidence))*10^(-10);
rand('state',S)

% [th, j] = sort(confidence); th = th(:);
% %th = th(fix(linspace(1, length(th), 150))); % here the number of points is hardcoded to be 150.
% th = th(2:end-1);
% 
% relevant = sum(testClass == 1);
% for t=1:length(th)
%     j = find(confidence > th(t));
%     retrieved(t) = length(j);
%     retrievedrelevant(t)  = sum(testClass(j) == 1);
% end
% 
% precision = 100*retrievedrelevant ./ retrieved;
% recall    = 100*retrievedrelevant / relevant;

% Compute Precision-Recall
[S,j] = sort(-confidence); % retrieved elements are the ones above or equal to the threshold
C = testClass(j);
n = length(C);

REL    = sum(testClass);
if n>0
    RETREL = cumsum(C);
    RET    = 1:n;
else
    RETREL = 0;
    RET    = 1;
end

precision = 100*RETREL ./ RET;
recall    = 100*RETREL  / REL;
th = -S;



% compute average precision (from PASCAL source code)
ap=0;
T = linspace(0,100,101);
for t=T % why so few bins?
    p=max(precision(recall>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/length(T);
end
averagePrecision = ap;


% Visualization
if nargin == 3
    plot(recall, precision, [col '-']); axis([0 100 0 100])

    grid on
    ylabel('Precision')
    xlabel('Recall')
    axis('square')
end
