% The SUN database has been annotated with objects and parts. This script
% dowloads the latest set of annotations and provides statistics about
% parts.

% 1) Download a copy of the SUN database
% This will take a while. Make sure you have around 50Gb available

yourpathimages = 'SUNDATABASE/Images';
yourpathannotations = 'SUNDATABASE/Annotations';
SUNinstall(yourpathimages, yourpathannotations)

% 2) create the index. You can jump into this step if you have already
% downloaded the database. 
%[D, folder, HOMEIMAGES, HOMEANNOTATIONS] = SUNdatabase('k/kitchen');
[D, folder, HOMEIMAGES, HOMEANNOTATIONS] = SUNdatabase;


% 3) get parts
[Dwithparts, j] = LMfindAnnotatedParts(D);

[objectPartStatistics] = LMpartstatistics(Dwithparts);

[Nimages, NimagesFullyAnnotated, NumberOfAnnotatedObjects, NumberOfAnnotatedObjectsWithParts, NumberOfParts] = SUNstats(D);



LMdbshowobjectparts(D, i);
