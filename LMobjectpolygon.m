function [x,y,jc,t,key] = LMobjectpolygon(annotation, name)
% [x,y] = LMobjectpolygon(annotation, name) returns all the polygons that
% belong to object class 'name'. Is it an array Ninstances*Nvertices
%
% [x,y] = LMobjectpolygon(annotation) % returns all the polygons
% [x,y] = LMobjectpolygon(annotation, 1:3) % returns the first three polygons


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
        x = []; y =[]; t = []; key = [];
    else
        for n = 1:Nobjects
            object = annotation.object(jc(n));
            [x{n},y{n},foo,key{n}] = getLMpolygon(object.polygon);
            if isfield(object, 'startFrame')
                t{n} = str2num(object.startFrame):str2num(object.endFrame);
            else
                t{n} = 1;
            end
        end
    end
else
    x = [];
    y = [];
    t =[];
    key = [];
    jc = [];
end

