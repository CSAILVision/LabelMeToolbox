function [year, month, counts, countUniqueImages, countObjectClasses] = evolutionAnnotations(D)
%
% lastweekStats(D, numberofdays)
%
% Plots a graph showing the number of objects annotated in the last days

% Create list of dates, image index, and object names
[D, objectnames] = LMcreateObjectIndexField(D);

labelingdate = [];
imagendx = [];
objndx = [];

p = 0;
for n = 1:length(D)
    if isfield(D(n).annotation, 'object')
        if isfield(D(n).annotation.object(1), 'date')
        for m = 1:length(D(n).annotation.object)
                d = D(n).annotation.object(m).date;
                if ~isempty(d)
                    p = p + 1;
                    labelingdate{p} = d(1:11);
                    imagendx(p) = n;
                    objndx(p) = D(n).annotation.object(m).namendx;
                end
            end
        end
    end
end
Labelingdate = datenum(labelingdate(1:p));

% % last week
% currentdate = datenum(date);
% labels = [];
% for i = 1:numberofdays
%     labels(i) = sum(Labelingdate == (currentdate-numberofdays+i));
% end
% 
% figure
% bar(labels)
% axis('tight')



% 2) evolution dataset/time
firstDate = datevec(min(Labelingdate));
lastDate  = datevec(max(Labelingdate));
yearRange = firstDate(1):lastDate(1);
monthRange = [1:12];
t = 0; dt = []; 
counts = []; 
countUniqueImages = [];
countObjectClasses = [];
year = [];
month = [];
for y = yearRange
    for m = monthRange
        d = (datenum(y,m,31));
        if d<max(Labelingdate) && d>min(Labelingdate)
            t = t+1;
            dt{t} = datestr(d);
            j = find(Labelingdate<d);
            counts(t) = length(j);
            countUniqueImages(t) = length(unique(imagendx(j)));
            countObjectClasses(t) = length(unique(objndx(j)));
            year(t) = y;
            month(t) = m;
        end
    end
end
