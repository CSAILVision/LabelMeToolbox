function varargout = LMupdate(varargin)

%

% Update local annotations. Reads the annotations from the web and replaces

% your local files with the new ones. 

%

% database = LMupdate(folderlist, filelist, HOMEIMAGES, HOMEANNOTATIONS);

%

% FOLDERLIST - Cell array containing directory names to update.

% FILELIST - Cell array containing image names (e.g. foo.jpg) to update.

%            Note that FOLDERLIST and FILELIST must be the same length.

% HOMEIMAGES - String that points to the location of the images.

% HOMEANNOTATIONS - String that points to the lcoation of the

%                   annotations.

% DATABASE - (Optional) Returned database structure containing

%            annotations for the images as specified in FOLDERLIST and

%            FILELIST.

%

% database = LMupdate(database_in, HOMEIMAGES, HOMEANNOTATIONS);

%

% This will update the annotation files that are in the DATABASE_IN

% structure and returns an updated database structure.

%

% DATABASE_IN - Existing database structure.  

%

% Revised: 2/13/2006 <brussell@csail.mit.edu>





  if nargin==3

    D = varargin{1};

    HOMEIMAGES = varargin{2};

    HOMEANNOTATIONS = varargin{3};

    [folderlist,filelist] = create_lists(D);

  elseif nargin>3

    D = [];

    folderlist = varargin{1};

    filelist = varargin{2};

    HOMEIMAGES = varargin{3};

    HOMEANNOTATIONS = varargin{4};

  else

    error('LMupdate: You need at least 3 arguments.');

  end



  create_DBstruct = 0;

  if length(nargout)>0

    create_DBstruct = 1;

  end

  

  Nimages = length(folderlist);

  webpage = 'http://people.csail.mit.edu/brussell/research/LabelMe/Annotations'



  for i = 1:Nimages

    annotationFileName = fullfile(HOMEANNOTATIONS, folderlist{i}, strrep(filelist{i}, '.jpg', '.xml'));

    imageline = [webpage '/' folderlist{i} '/' strrep(filelist{i}, '.jpg', '.xml')];

    xml = urlread(imageline);

    

    annotationFileName

    % Open file

    fid = fopen(annotationFileName,'w');

    fprintf(fid, xml);

    % Close file

    fclose(fid);

  

    if create_DBstruct

      [v,xml] = loadXML(annotationFileName);



      % add view point into the object name

      if isfield(v.annotation, 'object')

        for j = 1:length(v.annotation.object)

          if isfield(v.annotation.object(j), 'viewpoint')

            if ~isempty(v.annotation.object(j).viewpoint)

              a = str2num(v.annotation.object(j).viewpoint.azimuth);

              v.annotation.object(j).name = [v.annotation.object(j).name sprintf(' az%ddeg', a)];

            end

          end

        end

      end

      D(i).annotation = v.annotation;

    end

  end



  if create_DBstruct

    varargout{1} = D;

  end

  



function [folderlist,filelist] = create_lists(D)



  Nimages = length(D);

  folderlist = cell(1,Nimages);

  filelist = cell(1,Nimages);

  

  for ii = 1:Nimages

    folderlist{ii} = D(ii).annotation.folder;

    filelist{ii} = D(ii).annotation.filename;

  end

