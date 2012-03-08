function D = addsmallobjectlabel(D, height, width)
%
% D = addsmallobjectlabel(D, height, width)
%
% Add the 'smallobject' label to any object that both dimensions are
% smaller than 32 pixels:
% D = addsmallobjectlabel(D, 32, 32)
%
% Then we can use the LMquery to remove all the small objects.

for i = 1:length(D)
    if isfield(D(i).annotation, 'object')
        i
        Nobjects = length(D(i).annotation.object);
        bb = LMobjectboundingbox(D(i).annotation, 1:Nobjects)';       
        
        for j = 1:Nobjects
            H = bb(4,:)-bb(2,:); % height of each annotated object
            W = bb(3,:)-bb(1,:); % width of each annotated object

            small = find((H<height)&(W<width));

            for n = small
                D(i).annotation.object(n).name = [strtrim(D(i).annotation.object(n).name) ' smallobject'];
            end
        end
    end
end

