function labels = lastweekStats(D, numberofdays)
%
% lastweekStats(D, numberofdays)
%
% Plots a graph showing the number of objects annotated in the last days

% Create list of dates, image index, and object names
labelingdate = [];
p = 0;
for n = 1:length(D)
    if isfield(D(n).annotation, 'object')
        if isfield(D(n).annotation.object(1), 'date')
        for m = 1:length(D(n).annotation.object)
                d = D(n).annotation.object(m).date;
                if length(d)>0
                    p = p + 1;
                    labelingdate{p} = d(1:11);
                end
            end
        end
    end
end
Labelingdate = datenum(labelingdate(1:p));

% last week
currentdate = datenum(date);
labels = [];
for i = 1:numberofdays
    labels(i) = sum(Labelingdate == (currentdate-numberofdays+i));
end

figure
bar(labels)
axis('tight')

