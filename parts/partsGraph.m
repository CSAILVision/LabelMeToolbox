function [Ppart, objectClasses] = partsGraph(DB, objectClasses)
%
% Inputs:
%    DB - LabelMe DB structure.
%
% Outputs:
%    Ppart(i,j) - Probability of object class Oj is a part of Oi.
%    objectClasses - Cell array of object classes corresponding to the
%                    rows/cols of Ppart.

% Parameters:
Pp = 0.7; % probability of overlaping for between part and object. (it could be part of another object)
thresh_par = 0.90; % parts threshold (to collect local evidences)
Prior_part = 0.25; % prior prob of two objects being part of each other.

% Extract object classes:
if nargin == 1
    objectClasses = LMobjectnames(DB,'name');
end
objectClasses = lower(objectClasses);
Nobjects = length(objectClasses);
Nimages = length(DB);

% Compute part probabilities
PC_p = zeros([Nobjects, Nobjects], 'double'); % P(overlap | part)
PC_n = zeros([Nobjects, Nobjects], 'double'); % P(overlap | no part)
Counts = zeros([Nobjects, Nobjects], 'uint16'); % counts of coocurrences
for i = 1:Nimages
    display(sprintf('%d out of %d',i,Nimages));

    if isfield(DB(i).annotation,'object')
        [ncols, nrows] = getaproximagesize(DB(i).annotation);
        
        Nobj = length(DB(i).annotation.object);
        % Get object indices for this image
        clear ndx X Y area
        for j = 1:Nobj
            ndx(j) = strmatch(strtrim(lower(DB(i).annotation.object(j).name)), objectClasses, 'exact');
            [X{j},Y{j}] = getLMpolygon(DB(i).annotation.object(j).polygon);
            X{j}=double(X{j});
            Y{j}=double(Y{j});
            area(j) = polyarea(X{j},Y{j});
        end
        
        C = zeros(Nobj,Nobj, 'uint8');
        for m = 1:Nobj-1
            for n = m+1:Nobj
                C(m,n) = detectPart(X{n}, Y{n}, X{m}, Y{m}, thresh_par);
            end
        end
        C = C + C';
       
        
        % Get Pop for this image
        for clm = unique(ndx)
            m = find(ndx==clm);
            for cln = unique(ndx) % loop on classes in this image (each class counts only once as background)
                n = find(ndx==cln);
                
                if max(area(n)) > max(area(m)) % we expect the part to be the smaller object
                    % Detect parts
                    %clear C
                    %for k = 1:length(n)
                    %    C(k) = detectPart(X{n(k)},Y{n(k)},X{m},Y{m}, thresh_par);
                    %end
                    dC = sum(sum(C(n,m)))>0;

                    % Probability of overlap between two unrelated objects:
                    Pn = min(.99,max(0.01, max(sum(area(n)),sum(area(m)))/(eps+ncols*nrows))); % avoid NaN

                    % Compute likelihoods for part and no-part
                    %n = n(1);
                    PC_p(ndx(n(1)), ndx(m(1)))   = PC_p(ndx(n(1)), ndx(m(1))) + dC*log(Pp) + (1-dC)*log(1-Pp);
                    PC_n(ndx(n(1)), ndx(m(1)))   = PC_n(ndx(n(1)), ndx(m(1))) + dC*log(Pn) + (1-dC)*log(1-Pn);
                    
                    Counts(ndx(n(1)), ndx(m(1))) = Counts(ndx(n(1)), ndx(m(1))) + 1;
                end
            end
        end
    end
end



% Posterior:
% Ppart = PC_p*Prior_part ./ (PC_p*Prior_part+PC_n*(1-Prior_part));
ratio = exp(PC_n-PC_p) * (1-Prior_part)/Prior_part;
clear PC_n PC_p
Ppart = 1 ./ (1+ratio);
clear ratio

% Set to Prior_part all probabilities computed with small counts
Ppart = Ppart.*(Counts>5) + Prior_part.*(Counts<=5);
Ppart = Ppart-diag(diag(Ppart));

% Just for visualization:
[i,j] = find(Ppart>Prior_part & Counts>10); %only show results when there are enough samples
v = Ppart(sub2ind(size(Ppart),i,j));
[v,n] = sort(v, 'descend');
for k=n'
    disp(sprintf('%s is part of %s (with probability = %1.2f, estimated from %d samples)', objectClasses{j(k)}, objectClasses{i(k)}, Ppart(i(k),j(k)), Counts(i(k),j(k))))
end

disp('number of NaN')
M = sum(isnan(Ppart(:)))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function C = detectPart(X1,Y1,X2,Y2, thresh_par)
% Return logical indicator. Is O1/O2 part of O2/O1?

C = 0;

% Do fast approximation of intersection area:
Rn = [min(X1) min(Y1) max(X1) max(Y1)];
Rm = [min(X2) min(Y2) max(X2) max(Y2)];
if Rn(3)<Rm(1) || Rm(3)<Rn(1) || Rn(4)<Rm(2) || Rm(4)<Rn(2)
    return
end

[A,ua,area1,area2] = RectAreas(Rn,Rm);
if A/(min(area1,area2)+eps) > thresh_par
    [A,ua,area1,area2] = PolyAreas(X1,Y1,X2,Y2);
    % detect overlap
    C = (A/min(area1,area2)) > thresh_par;
end

function [int,union,A1,A2] = RectAreas(ro,rp)
% Fast intersection computation.  Used as a bound on the normalized
% intersection area.  Normalize by the area of the smaller rectangle.
% min_x,min_y,max_x,max_y  

  tt = 0;
  wo = ro(3)-ro(1);
  ho = ro(4)-ro(2);
  wp = rp(3)-rp(1);
  hp = rp(4)-rp(2);
  int = rectint([ro(1) ro(2) wo ho],[rp(1) rp(2) wp hp]);
  A1 = wo*ho;
  A2 = wp*hp;
  union = A1+A2-int;

  function [A,ua,area1,area2] = PolyAreas(X1,Y1,X2,Y2)
% Compute intersection and union areas, as well as areas of individual
% polygons
%
% [Aint,Aunion,A1,A2] = PolyAreas(X1,Y1,X2,Y2)

  max_res = 100;
  
  min_x = min([X1(:); X2(:)]);
  max_x = max([X1(:); X2(:)]);
  min_y = min([Y1(:); Y2(:)]);
  max_y = max([Y1(:); Y2(:)]);
  
  X1 = X1-min_x;
  X2 = X2-min_x;
  Y1 = Y1-min_y;
  Y2 = Y2-min_y;
  max_x = max_x - min_x;
  max_y = max_y - min_y;
  
  max_dim = max(max_x,max_y);
  
  X1 = X1*max_res/max_dim+1; 
  X2 = X2*max_res/max_dim+1;
  Y1 = Y1*max_res/max_dim+1; 
  Y2 = Y2*max_res/max_dim+1;
  
  max_x = ceil(max_x+1); 
  max_y = ceil(max_y+1);
  
  M1 = poly2mask(X1,Y1,max_res,max_res);
  M2 = poly2mask(X2,Y2,max_res,max_res);
  
  A = sum(sum(double(M1&M2)));
  ua = sum(sum(double((M1+M2)>0)));
  area1 = sum(double(M1(:)));
  area2 = sum(double(M2(:)));
