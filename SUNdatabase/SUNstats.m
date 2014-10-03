function [Nimages, NimagesFullyAnnotated, NumberOfAnnotatedObjects, NumberOfAnnotatedObjectsWithParts, NumberOfParts] = SUNstats(D)
%
%
% Number of images
% Number of fully annotated images
% Number of annotated objects
% Number of annotated root objects with parts
% Number of parts


% Number of images
Nimages = length(D);

% Number of fully annotated images
disp('Counting fully labeled images')
relativearea = LMlabeledarea(D);
NimagesFullyAnnotated = sum(relativearea>.9);

% Number of annotated objects

% Number of annotated root objects with parts
[counts, countrootwithparts, countparts] = LMcountparts(D);

NumberOfAnnotatedObjects = sum(counts);
NumberOfAnnotatedObjectsWithParts = sum(countrootwithparts);
NumberOfParts = sum(countparts);

fprintf('Number of images= %d \n', Nimages)
fprintf('Number of images (90%%) labeled = %d \n', NimagesFullyAnnotated)
fprintf('Number of annotated objects = %d \n', NumberOfAnnotatedObjects)
fprintf('Number of annotated objects with parts = %d \n', NumberOfAnnotatedObjectsWithParts)
fprintf('Number of annotated parts = %d \n', NumberOfParts)

