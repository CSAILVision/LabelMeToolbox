function D = addsmallobjectlabel(D, height, width, method)
%
% D = addsmallobjectlabel(D, height, width)
%
% Add the 'smallobject' label to any object that both dimensions are
% smaller than 32 pixels:
%
% D = addsmallobjectlabel(D, 32, 32)
%
% You can specify two decisions:
% D = addsmallobjectlabel(D, 32, 32, method)
%
% method = [and] | or
% 
%
% Then we can use the LMquery to remove all the small objects.

if nargin<4
    method = 'and';
end

for i = 1:length(D)
    if isfield(D(i).annotation, 'object')
        Nobjects = length(D(i).annotation.object);
        bb = LMobjectboundingbox(D(i).annotation, 1:Nobjects)';       
        
        for j = 1:Nobjects
            H = bb(4,:)-bb(2,:); % height of each annotated object
            W = bb(3,:)-bb(1,:); % width of each annotated object

            switch method
                case 'and'
                    small = find((H<height)&(W<width));
                case 'or'
                    small = find((H<height)|(W<width));
                otherwise
                    error('Invalid method')
            end

            for n = small
                D(i).annotation.object(n).name = [strtrim(D(i).annotation.object(n).name) ' smallobject'];
            end
        end
    end
end

