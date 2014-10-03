% This script updates and stores the labelme index in the toolbox folder

% Update index
HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations';
HOMEIMAGES = 'http://labelme.csail.mit.edu/Images';

% Rebuild index
Dlabelme = LMdatabase(HOMEANNOTATIONS);

% Save index in the toolbox folder
lastupdate = sprintf('This index was created on the %s', date);
toolboxfolder = strrep(which('UPDATEINDEX.m'), 'UPDATEINDEX.m', '');
save(fullfile(toolboxfolder, 'Dlabelme'), 'Dlabelme', 'lastupdate')

