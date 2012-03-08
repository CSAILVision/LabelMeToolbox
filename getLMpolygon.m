function [x,y,t,key] = getLMpolygon(polygon)
%
% Utility function that gives the coordinates of the polygon's vertices
%

Nframes = length(polygon);
key = 1;
t=[];

if Nframes == 0
    x=[]; y=[]; key=[];
    return
end


if Nframes == 1
    [x,y,key] = getpol(polygon);
    %if size(x,2)>1
    %    t = polygon.t;
    %else
        t = 1;
    %end
else
    [xx,yy,key] = getpol(polygon(1));

    Npoints = length(xx);
    x = zeros([Npoints Nframes], 'single');
    y = zeros([Npoints Nframes], 'single');    
    %t = zeros([1 Nframes], 'uint16');
    key = zeros([Npoints Nframes], 'uint8');
    
    x(:,1) = xx;
    y(:,1) = yy;
    %t(1) = str2num(polygon(1).t);
    for n = 2:Nframes
        [x(:,n),y(:,n),key(:,n)] = getpol(polygon(n));
        %t(n) = str2num(polygon(n).t);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y,key] = getpol(polygon)
% utility function

key = 1;

if isfield(polygon, 'x')
    %x = double(polygon.x);
    %y = double(polygon.y);
    x = (polygon.x);
    y = (polygon.y);
    if isfield(polygon, 'key')
        key = uint8(polygon.key); % get Y polygon coordinates
    end
elseif isfield(polygon, 'pt')
    x = str2num(char({polygon.pt.x})); % get X polygon coordinates
    y = str2num(char({polygon.pt.y})); % get Y polygon coordinates
    if isfield(polygon.pt, 'l')
        key = str2num(char({polygon.pt.l})); % get Y polygon coordinates
    end
else
    x = [];
    y = [];
    key = [];
end

