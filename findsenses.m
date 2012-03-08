function [wordnet, counts] = findsenses(D, name)
%
% Looks at the wordnet field in D and return all the different senses that
% are returned when using 'name' for query.
%
% Example:
%  wordnet = findsenses(D, 'screen-device');
%    shutter. blind, screen. protective covering, protective cover, protection. covering. artifact, artefact. whole, unit. object, physical object. physical entity. entity. 
%    windshield, windscreen. screen. protective covering, protective cover, protection. covering. artifact, artefact. whole, unit. object, physical object. physical entity. entity. 
%                           
%  wordnet = findsenses(D, 'screen+device');
%    computer screen, computer display. screen, CRT screen. display, video display. electronic device. device. instrumentality, instrumentation. artifact, artefact. whole, unit. object, physical object. physical entity. entity. 
%    screen, CRT screen. display, video display. electronic device. device. instrumentality, instrumentation. artifact, artefact. whole, unit. object, physical object. physical entity. entity. 

if nargin == 2
    D = LMquery(D, 'object.synset', name);
end

Nannotations = length(D);

wordnet = [];
for i = 1:Nannotations
    if isfield(D(i).annotation, 'object')
        if isfield(D(i).annotation.object, 'synset')
            N = length(D(i).annotation.object);
            wordnet = [wordnet {D(i).annotation.object(:).synset}];
        end
    end
end

% Extract unique senses and counts
[wordnet, i, j] = unique(wordnet);
Nsenses = length(wordnet);
[counts, x] = hist(j, 1:Nsenses);
