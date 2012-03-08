function arrangefigs(h)
%
% Uses:
% 
% 1) No parameters: organizes current figures
%   arrangefigs 
%
% 2) Organizes the first 4 figures (creates figures if they do not exist)
%   arrangefigs (4)
%
% 3) Organizes only the figures on the list
%   arrangefigs ([1 3 10])

N = nargin;

if N==0
    h = get(0, 'children');
else
    if length(h) == 1
        h = 1:h;
    end
end

Nfigs = length(h);
sc = get(0, 'ScreenSize');

ncols = ceil(sqrt(Nfigs+1));
nrows = ceil((Nfigs+1) / ncols);

yoffset = 40;
xoffset = 1;
spacingx = 5;
spacingy = 5;

wx = (sc(3)-xoffset)/ncols;
wy = (sc(4)-yoffset)/nrows;

f = 0;
for r = 1:nrows
    for c = 1:ncols
        f = f+1;
        
        if f > Nfigs
            return
        else
            figure(h(f))

            x = (c-1)*wx;
            y = (nrows-r)*wy;
            set(h(f), 'position', [x+xoffset y+yoffset wx-spacingx wy-spacingy-70])
        end
    end
end
