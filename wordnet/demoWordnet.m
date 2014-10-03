% This demo shows how to use Wordnet with LabelMe. 
% WordNet (http://wordnet.princeton.edu)
% Citation: WordNet: An Electronic Lexical Database, MIT Press.
% http://wordnet.princeton.edu/license
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% First, create database index
HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations';
HOMEIMAGES = 'http://labelme.csail.mit.edu/Images';
D = LMdatabase(HOMEANNOTATIONS);

% Add wordnet:
sensesfile = 'wordnetsenses.txt'; % this file contains the list of wordnet synsets.
[D, unmatched, counts] = LMaddwordnet(D, sensesfile)

% The LMaddwordnet command creates a new field for each object:
%  D(i).annotation.object(j).synset
%
% unmatched contains a list of all the object descriptions that are not in
% the dictionary. They can be added by hand.

% Now you can query using the wordnet hierarchy:
Dq = LMquery(D, 'object.synset', 'animal');

% This will return all the animals in the dataset despite that the word animal is not part
% of the LabelMe raw annotations.

% You can find all the posible senses:
wordnet = findsenses(D, 'screen');
% this will show that there are multiple senses for the word screen. This
% will help you to narrow down the query to get the images you want.

% Example:
wordnet = findsenses(D, 'screen-device');
% This will return the senses:
%    shutter. blind, screen. protective covering, protective cover, protection. covering. artifact, artefact. whole, unit. object, physical object. physical entity. entity. 
%    windshield, windscreen. screen. protective covering, protective cover, protection. covering. artifact, artefact. whole, unit. object, physical object. physical entity. entity. 
%                           

wordnet = findsenses(D, 'screen+device');
% This will return the senses:
%    computer screen, computer display. screen, CRT screen. display, video display. electronic device. device. instrumentality, instrumentation. artifact, artefact. whole, unit. object, physical object. physical entity. entity. 
%    screen, CRT screen. display, video display. electronic device. device. instrumentality, instrumentation. artifact, artefact. whole, unit. object, physical object. physical entity. entity. 


% You can visualize a tree with all the senses using:
tree = wordnetTree('wordnetsenses.txt');
showTree(tree)



