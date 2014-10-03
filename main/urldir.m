function [files, status] = urldir(page, tag)
%
% Lists the files within a URL
%
% Collecion of folders:
% files = urldir(page, 'DIR')
% Collection of files:
% files = urldir(page, 'TXT')

% Created: A. Torralba, 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LabelMe, the open annotation tool
% Contribute to the database by labeling objects using the annotation tool.
% 
% CSAIL, MIT
% 2006
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
    tag = '[dir]';
    tag = '/'
else
    tag = lower(tag);
    if strcmp(tag, 'dir')
        tag = '/';
    end
    if strcmp(tag, 'txt')
        tag = 'xml';
    end
    if strcmp(tag, 'img')
        tag = 'jpg';
    end
end

nl = length(tag);
nfiles = 0;
files = [];

% Read page
page = strrep(page, '\', '/');
status =0;
trials = 0;
while status == 0 && trials<10
    [webpage, status] = urlread(page, 'Timeout', 5);
    if status == 0
        disp(sprintf('Warning: Failure urldir %s. Trying again...',page))
        drawnow
        trials = trials+1;
    end
end

if trials == 10
    disp('warning: skipping this folder...')
    status = 1;
    return
end

if status
    % Parse page
    j1 = findstr(lower(webpage), '<a href="');
    j2 = findstr(lower(webpage), '</a>');
    Nelements = length(j1);
    if Nelements>0
        for f = 1:Nelements
            % get HREF element
            chain = webpage(j1(f):j2(f));
            jc = findstr(lower(chain), '">');
            if ~isempty(jc)
                chain = deblank(chain(10:jc(1)-1));
                
                % check if it is the right type
                if length(chain)>length(tag)-1
                    if strcmp(chain(end-nl+1:end), tag)
                        nfiles = nfiles+1;
                        chain = strrep(chain, '%20', ' '); % replace space character
                        files(nfiles).name = chain;
                        files(nfiles).bytes = 1;
                    end
                end
            end
        end
    end
end
