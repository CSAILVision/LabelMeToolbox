function Dout = LMquerydetections(D, query, value)
% Dout = LMquerydetections(DdetectorTest, 'top', 100)
% LMquerydetections(DdetectorTest, 'confidence', .9)
% LMquerydetections(DdetectorTest, 'topperimage', 4)

% get all the scores and associate an image index and an object index to
% each one

Dout = [];

Nimages = length(D);
maxScore = zeros([Nimages 1]);
minScore = zeros([Nimages 1]);
for n = 1:Nimages
    % baseline
    if ~isfield(D(n).annotation.object, 'p_w_s')
    scores = [D(n).annotation.object.confidence];
    else
    scores = [D(n).annotation.object.p_w_s];
    end
    type = ismember({D(n).annotation.object.detection}, {'correct'});
    
    maxScore(n) = max(scores);
    minScore(n) = min(scores);
    
    %imgndx{n} = 
    %objndx{n} = 
    switch query
        case 'topperimage'
            [foo,j] = sort(scores, 'descend');
            annotation = D(n).annotation;
            annotation.object = annotation.object(j(1:min(value, length(j))));
            Dout(n).annotation = annotation;
    end
end

switch query
    case 'top'
        [foo,j] = sort(minScore, 'descend');
        Dout = D(j(1:min(value, length(j))));
end