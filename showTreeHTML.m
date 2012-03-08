function showTreeHTML(tree)
% showTreeHTML(tree)
%
% tree = specifies the tree. It contains two fields:
%    tree.parent   this uses the Matlab structure for specifiying trees
%    (is a list of parents)
% tree.nodewords = is a cell array. Each element is the name associated
%    with each node.


pagename = 'test.html'

threshold = 0;

% Hearder
page = {};
page = addline(page, '<html><head><title>LabelMe tree</title><body>');
page = addline(page, '<img src="http://labelme.csail.mit.edu/Icons/LabelMeNEWtight198x55.gif" height=55 alt=":LabelMe" />');
page = addline(page, '<b>+ <a href="http://wordnet.princeton.edu/">WordNet</a></b><br>');

%page = addline(page, '<b><font size=5> Photoalbum</font></b><br>');
%page = addline(page, '<hr align="Left" size="1"><br>');
%page = addline(page, '<font size=2>');
% page = addline(page, drawlinehtml(10,10,40,30));
% page = addline(page, drawlinehtml(10,10,20,30));
% page = addline(page, drawlinehtml(10,10,50,30));
% page = addline(page, drawlinehtml(10,10,0,30));

page = addline(page, 'LabelMe by MIT.<br>');
page = addline(page, 'WordNet 2.1 Copyright 2005 by Princeton University.<br>');

page = addline(page, '<div style="position:absolute; top:120px; left: 6px; background-color:yellow;">');
page = addline(page, 'Use the scroll bars to view different parts of the tree.<br>');
page = addline(page, 'If you use Firefox, use the CTRL+ and CTRL- to zoom in and out.<br>');
page = addline(page, 'Click on one word to see the object images.<br>');


p = tree.parent;
[x,y,h,s] = trimtreelayout(tree.parent);
x = round(x*1000);
y = round((1-y)*400);

x = x+rand(size(x))*2;
y = y+rand(size(y))*max(y)/50;
y = y-min(y(:))+1;

f = find(p~=0);
pp = p(f);

% figure
% hold on; axis('ij')
% for i = 1:length(f)
%     page = addline(page, drawlinehtml(x(f(i)), y(f(i)), x(pp(i)), y(pp(i))));
%     plot([x(f(i)) x(pp(i))], [y(f(i)) y(pp(i))])
% end

% figure
% trimtreeplot(tree.parent);
% hold on
for n = 1:length(x)
    if tree.counts(n)>threshold
        p =  tree.parent(n);
        if p>0
            page = addline(page, drawlinehtml(x(n), y(n), x(p), y(p)));
        end
    end
end

for n = 1:length(x)
    chain = tree.nodewords{n};
    w=getwords(chain); w = w{1};
    w(1) = upper(w(1));
    
    if tree.counts(n)>threshold
        page = addline(page, texthtml(x(n), y(n), chain));
        text (x(n), y(n), w, 'fontsize', 3)
    end
end








% Close web page

page = addline(page, '</body></html>');

page = strrep(page, '  ', ' ');
page = strrep(page, '  ', ' ');

% write web page
fid = fopen(pagename,'w');
for i = 1:length(page); 
    fprintf(fid, [page{i} '\n']); 
end
fclose(fid);


function page = addline(page, line)
page = [page {line}];


function line = texthtml(x,y,s)
%line{1} = sprintf('<div style="position:absolute; top:%5.1fem; left: %5.1fem; background-color:yellow;">%s</div>', y-.5, double(x)-length(s)/4, s);

% Anyadir a la query los terminos de la rama. No usar solo la leave. Por
% ejemplo, en mouse, hacer la query con "mouse + device", al menos usar el
% siguente padre.

w = getwords(s); 
w = w{1};
w(1) = upper(w(1));

sq = strrep(s, ',', '');
sq = strrep(sq, '-', ' ');

line = sprintf('<div style="position:absolute;top:%5.1fem;left:%5.1fem;background-color:yellow;">', y-.5, double(x)-length(w)/4);
line = [line sprintf('<a href="http://people.csail.mit.edu/torralba/research/LabelMe/js/LabelMeQueryObjectFast.cgi/?query=%s" title="%s">', sq, s)];
line = [line sprintf('%s</a></div>', w)];




function line = drawlinehtml(x1,y1,x2,y2)
cols = [1 2 4 8 16 32 64 128 256];

r = 128*abs(x2-x1)/abs(y2-y1);
bestratio = find(r-cols>0);
cols = [1 2 4 8 16 32 64 128 256 256];
if length(bestratio)==0
    bestratio = cols(1);
else
    bestratio = cols(bestratio(length(bestratio))+1);
end

if abs(x2-x1)<1
    x1 = x2+.2*sign(rand-.5);
    bestratio = 2;
end

if y2<y1
    tmp = x1; x1=x2; x2 = tmp;
    tmp = y1; y1=y2; y2 = tmp;
end
if x2>x1
    line = sprintf('<div style="position:absolute;top:%5.1fem;left: %5.1fem;">', y1, x1);
    line = [line sprintf('<img style="width:%5.1fem;height:%5.1fem;border:0px;" src="lineright_%d.gif">',  x2-x1, y2-y1, bestratio)];
    line = [line '</div>'];
else
    line = sprintf('<div style="position:absolute;top:%5.1fem;left:%5.1fem;">', y1, x2);
    line = [line sprintf('<img style="width:%5.1fem;height:%5.1fem;border:0px;" src="lineleft_%d.gif">', (x1-x2), (y2-y1), bestratio)];
    line = [line '</div>'];
end



function [x,y,h,s] = trimtreelayout(parent,post)
%   TRIMTREELAYOUT A modified standard function TREELAYOUT. 
%     Produces different heights for the leaves. They appear in
%     their respective layer instead of the deepest layer. The
%     format is the same as for TREELAYOUT, see below.
%
%   [x,y,h,s] = trimtreelayout(parent,post)
% 
%
%   TREELAYOUT Lay out tree or forest.
%   [x,y,h,s] = treelayout(parent,post)
%       parent is the vector of parent pointers, with 0 for a root.
%       post is a postorder permutation on the tree nodes.
%       (If post is omitted we compute it here.)
%       x and y are vectors of coordinates in the unit square at which 
%       to lay out the nodes of the tree to make a nice picture.
%       Optionally, h is the height of the tree and s is the 
%       number of vertices in the top-level separator.
%
%   See also ETREE, TREEPLOT, ETREEPLOT, SYMBFACT.

%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision: 5.11 $  $Date: 2000/06/08 20:18:46 $
% 
%   Modified by RG 01-Nov-1 to plot the leaves in the right layer
%

% This is based on the C code in sptrees.c by John Gilbert.
% Leaves are spaced evenly on the x axis, and internal
% nodes are centered over their descendant leaves with
% y coordinate proportional to height in the tree.

n = length(parent);

 pv = [];
 if (size(parent,1)>1), parent = parent(:)'; end
 if (nargin<2) & ~all(parent==0 | parent>(1:n))
     % This does not appear to be in the form generated by ETREE.
     if (any(parent>n) | any(parent<0) | any(parent~=floor(parent)) ...
	 | any(parent==[1:n]))
        error('Bad vector of parent pointers.');
     end
     [parent,pv] = fixparent(parent);
 end

if nargin < 2,

    % Create the adjacency matrix A of the given tree,
    % and get the postorder with another call to etree.

    j = find(parent);
    A = sparse (parent(j), j, 1, n, n);
    A = A + A' + speye(n,n);
    [ignore, post] = etree(A);
%    post
end;

% Add a dummy root node #n+1, and identify the leaves.

parent = rem(parent+n, n+1) + 1;  % change all 0s to n+1s
isaleaf = ones(1,n+1);
isaleaf(parent) = zeros(n,1);

% In postorder, compute heights and descendant leaf intervals.
% Space leaves evenly in x (in postorder).

xmin = n(1,ones(1,n+1)); % n+1 copies of n
xmax = zeros(1,n+1);
height = zeros(1,n+1);
nkids = zeros(1,n+1);
nleaves = 0;

for i = 1:n,
    node = post(i);
    if isaleaf(node),
        nleaves = nleaves+1;
        xmin(node) = nleaves;
        xmax(node) = nleaves;
    end;
    dad = parent(node);
    %RG
%    height(dad) = max (height(dad), height(node)+1);
    xmin(dad)   = min (xmin(dad),   xmin(node));
    xmax(dad)   = max (xmax(dad),   xmax(node));
    nkids(dad)  = nkids(dad)+1;
end;

% RG compute heights
% traverse the tree from the root downwards in a layer-manner
lay_ind = n+1;
par_ind = n+1;
while(1)
  lay_ind = find(ismember(parent, lay_ind));
  if isempty(lay_ind)
    break;
  end  
  par_ind = [par_ind lay_ind];
  height(par_ind) = height(par_ind)+1;
end
height(1:n) = height(1:n)-1;

% Compute coordinates, leaving a little space on all sides.

treeht = height(n+1) - 1;
deltax = 1/(nleaves+1);
deltay = 1/(treeht+2);
x = deltax * (xmin+xmax)/2;
y = deltay * (height+1);

% Omit the dummy node.

x = x(1:n);
y = y(1:n);

% Return the height and top separator size.


h = treeht;
s = n+1 - max(find(nkids~=1));

if ~isempty(pv)
   x(pv) = x;
   y(pv) = y;
end

% ----------------------------
function [a,pv] = fixparent(parent)
%FIXPARENT  Fix order of parent vector
%   [A,PV] = FIXPARENT(B) takes a vector of parent nodes for an
%   elimination tree, and re-orders it to produce an equivalent vector
%   A in which parent nodes are always higher-numbered than child
%   nodes.  If B is an elimination tree produced by the TREE
%   functions, this step will not be necessary.  PV is a
%   permutation vector, so that A = B(PV);

n = length(parent);
a = parent;
a(a==0) = n+1;
pv = 1:n;

niter = 0;
while(1)
   k = find(a<(1:n));
   if isempty(k), break; end
   k = k(1);
   j = a(k);
   
   % Put node k before its parent node j
   a  = [ a(1:j-1)  a(k)  a(j:k-1)  a(k+1:end)]; 
   pv = [pv(1:j-1) pv(k) pv(j:k-1) pv(k+1:end)]; 
   t = (a >= j & a < k);
   a(a==k) = j;
   a(t) = a(t) + 1;

   niter = niter+1;
   if (niter>n*(n-1)/2), error('Bad vector of parent pointers.'); end
end

a(a>n) = 0;


function trimtreeplot(p,c,d)
% TRIMTREEPLOT A modified standard function TREEPLOT. Plots the
%   leaves differently from TREEPLOT. They appear in their
%   respective layer instead of the deepest layer so that the tree
%   appears as "trimmed". The format is the same as for TREEPLOT,
%   see below. 
%
% trimtreeplot(p [,c,d])
%
% TREEPLOT Plot picture of tree.
%   TREEPLOT(p) plots a picture of a tree given a vector of
%   parent pointers, with p(i) == 0 for a root. 
%
%   TREEPLOT(P,nodeSpec,edgeSpec) allows optional parameters nodeSpec
%   and edgeSpec to set the node or edge color, marker, and linestyle.
%   Use '' to omit one or both.
%
%   See also ETREE, TREELAYOUT, ETREEPLOT.

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.8 $  $Date: 1997/11/21 23:44:59 $
%
%   Modified by RG 01-Nov-1 to use trimtreelayout instead of
%   TREELAYOUT 

% RG use another treelayout 
%[x,y,h]=treelayout(p);
[x,y,h]=trimtreelayout(p);

f = find(p~=0);
pp = p(f);
X = [x(f); x(pp); repmat(NaN,size(f))];
Y = [y(f); y(pp); repmat(NaN,size(f))];
X = X(:);
Y = Y(:);

if nargin == 1,
    n = length(p);
    if n < 500,
        plot (x, y, 'ro', X, Y, 'r-');
    else,
        plot (X, Y, 'r-');
    end;
else,
    [ignore, clen] = size(c);
    if nargin < 3, 
        if clen > 1, 
            d = [c(1:clen-1) '-']; 
        else,
            d = 'r-';
        end;
    end;
    [ignore, dlen] = size(d);
    if clen>0 & dlen>0
        plot (x, y, c, X, Y, d);
    elseif clen>0,
        plot (x, y, c);
    elseif dlen>0,
        plot (X, Y, d);
    else
    end;
end;
xlabel(['height = ' int2str(h)]);
axis([0 1 0 1]);
