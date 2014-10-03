function [aROC, falseAlarmRate, detectionRate] = areaROC(confidence, testClass, col)
% You pass the scores and the classes, and the function returns the false
% alarm rate and the detection rate for different points across the ROC.
%
% [faR, dR] = plotROC(score, class)
%
% it generates 150 points. 
%  faR (false alarm rate) is uniformly sampled from 0 to 1
%  dR (detection rate) is computed using the scores.
%
% class = 0 => target absent
% class = 1 => target present
%
% score is the output of the detector, or any other measure of detection.
% There is not plot unless you add a third parameter that is the color of
% the graph. For instance:
% [faR, dR] = plotROC(score, class, 'r')

S = rand('state');
rand('state',0);
confidence = confidence + rand(size(confidence))*10^(-10);
rand('state',S)

ndxAbs = find(testClass<=0); % absent
ndxPres = find(testClass==1); % present

[th, j] = sort(confidence(ndxAbs));
th = th(fix(linspace(1, length(th), 320))); % here the number of points is hardcoded to be 150.

cAbs = confidence(ndxAbs);
cPres = confidence(ndxPres);
for t=1:length(th)
  detectionRate(t)  = sum(cPres>=th(t)) / length(ndxPres);
  falseAlarmRate(t) = sum(cAbs>=th(t)) / length(ndxAbs);
end

aROC = abs(sum((falseAlarmRate(2:end)-falseAlarmRate(1:end-1)).*(detectionRate(2:end) +detectionRate(1:end-1))/2));

if nargin == 3
    plot(falseAlarmRate, detectionRate, [col '-']); axis([0 1 0 1])

    grid on
    ylabel('detection rate')
    xlabel('false alarm rate')
    axis('square')
end
