function boundingbox = LMobjectboundingbox(annotation, name)
% boundingbox = LMobjectboundingbox(annotation, j) 
%     returns the bounding box of polygon index j
%
% boundingbox = LMobjectboundingbox(annotation, name) 
%     returns all the bounding boxes that
%     belong to object class 'name'. Is it an array Ninstances*4
%
% boundingbox = [xmin ymin xmax ymax]


% [x,y,jc] = LMobjectpolygon(annotation, varargin{:});
% 
% Nobjects = length(x);
% if Nobjects == 0
%     boundingbox = [];
% else
%     boundingbox = zeros(Nobjects,4);
%     for n = 1:Nobjects
%         %[xn yn] = getLMpolygon(annotation.object(jc(n)).polygon);
%         boundingbox(n,:) = [min(x{n}) min(y{n}) max(x{n}) max(y{n})];
%     end
% end

  

if isfield(annotation, 'object')
    if nargin == 1
        jc = 1:length(annotation.object);
    else
        if ischar(name)
            jc = LMobjectindex(annotation, name);
        else
            jc = name;
        end
    end

    Nobjects = length(jc);
    if Nobjects == 0
        boundingbox = [];
    else
        boundingbox = zeros(Nobjects,4);
        for n = 1:Nobjects
            [x,y] = getLMpolygon(annotation.object(jc(n)).polygon);
            boundingbox(n,:) = [min(x) min(y) max(x) max(y)];
        end
    end
else
    x = [];
    y = [];
    t =[];
    key = [];
    jc = [];
end

  