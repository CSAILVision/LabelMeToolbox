function wordnetGUI(D, sensesfile)

HOMEANNOTATIONS = 'http://labelme.csail.mit.edu/Annotations';
HOMEIMAGES = 'http://labelme.csail.mit.edu/Images';

% load database struct
if nargin ==0
    D = LMdatabase(HOMEANNOTATIONS);
end

% load wordnet file.
if nargin < 2
    sensesfile = 'wordnetsenses.txt';
end

% % get list of descriptions used in LabelMe
% disp('Extracting list of descriptions from LabelMe')
% [descriptions2, counts] = LMobjectnames(D);
%
%
% % load list of stop words
% stopwords = removestopwords;
%
% for i = 1:Ndescriptions
%     % remove common words
%     descriptions{i} = removestopwords(descriptions{i}, stopwords);
% end
% [descriptions,j] = unique(descriptions);
% counts = counts(j);
%
% % sort descriptions by counts
% [counts, j] = sort(-counts); counts = - counts;
% descriptions = descriptions(j);
% Ndescriptions = length(descriptions);
%
% % Remove from the list all the descriptions that have already senses
% % assigned
% if exist(sensesfile)
%     C = importdata(sensesfile);
%     done = C(1:4:end);
%     new = [];
%     for i = 1:Ndescriptions
%         j = strmatch(descriptions{i}, done, 'exact');
%         if length(j) == 0
%             new = [new i];
%         end
%     end
%     descriptions = descriptions(new);
% end
%

global sense

if exist(sensesfile, 'file')
    [D, descriptions, counts] = LMaddwordnet(D, sensesfile);
    Ndescriptions = length(descriptions);
else
    [descriptions, counts] = LMobjectnames(D);
end
Ndescriptions = length(descriptions);
    
% Create GUI
sc=get(0,'ScreenSize'); sc(1) = 1; sc(2) = 1;
close
figure(1)
clf('reset')
set(1,'position', sc);
set(1,'color',[0.8 0.8 0.8])
set(1,'doublebuffer','on');
set(1,'BackingStore','off');
set(1,'NumberTitle','off')
set(1,'menubar','none')
set(1,'units','pixels')
set(1,'position',sc);
set(1,'Interruptible','off');
set(1,'BusyAction','queue');
sc = get(1, 'position');


for i = 1:Ndescriptions
    if length(descriptions{i})>0
        [word, found] = getWordnetSense(descriptions{i});
        if found == 1
            synonims = [word(:).synonyms];
            branch = [word(:).branch];
            synsets = [word(:).sense];
            frequency = [word(:).frequency];

            n = length(synonims);
            
            % Show main text
            clf(1)
            subplot(6,3,1)
            text(0,1,sprintf('Description: %d, counts:%d (/%d)', i, counts(i), sum(counts(i+1:end))))
            axis('off')
            subplot(6,3,2)
            %img = imread();
            title(descriptions{i})
            axis('off')

            % Plot sense buttons
            for c=1:n
                %message = [synonims{c} '   '  synsets{c}];
                message = [synonims{c}  '   ' branch{c}{1} '.' branch{c}{2} '.' branch{c}{3}];

                h2 = uicontrol('Parent',1, ...
                    'Units','pixels', ...
                    'Callback', sprintf('global sense; sense = %d', c), ...
                    'ListboxTop', 0, ...
                    'Position',[100 sc(4)*.8-c*35 sc(3)-200 27], ...
                    'String', message, ...
                    'Tag', 'Pushbutton1');
            end

            h2 = uicontrol('Parent',1, ...
                'Units','pixels', ...
                'Callback', 'global sense; sense = -1;', ...
                'ListboxTop',0, ...
                'Position',[100 sc(4)*.8-(c+1.5)*35 sc(3)-200 27], ...
                'String', 'None of the above', ...
                'Tag','Pushbutton1');

            drawnow

            % Wait until the user wants to add a new object
            sense = 0;
            while sense == 0
                drawnow
            end
            clf(1)

            % Write line
            if sense > 0
                disp('save')
                fid = fopen(sensesfile,'a');
                fprintf(fid,'%s\n', descriptions{i});
                fprintf(fid,'   %s\n', synonims{sense});
                fprintf(fid,'   %s\n', synsets{sense});
                fprintf(fid,'\n', synsets{sense});
                fclose(fid);
            end
        end
    end
end




