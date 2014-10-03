function [annotation, img] = LMimpad(annotation, img, PADSIZE, PADVAL)
% [annotation, img] = LMimpad(annotation, img, PADSIZE, PADVAL)
%
% [annotation, img] = LMimpad(annotation, img, [256 256], 0)
% PADSIZE = nrows x ncols (final image size)
% PADVAL = value for the border

[nrows, ncols, cols]=size(img);

if PADSIZE(1)<nrows || PADSIZE(2)<ncols
    error('ERROR: image is larger than target size. Use LMimcrop instead.')
end

Dy = fix((PADSIZE(1)-nrows)/2);
Dx = fix((PADSIZE(2)-ncols)/2);


img = [repmat(PADVAL, [PADSIZE(1) Dx cols]) ...
    [repmat(PADVAL, [Dy ncols cols]); img; repmat(PADVAL, [PADSIZE(1)-nrows-Dy ncols cols])] ...
    repmat(PADVAL, [PADSIZE(1) PADSIZE(2)-ncols-Dx cols])];

% Change the polygon coordinates
if isfield(annotation, 'object')
    Nobjects = length(annotation.object); n=0;
    for i = 1:Nobjects
        [x,y] = getLMpolygon(annotation.object(i).polygon);
        x = round(x + Dx);
        y = round(y + Dy);
        annotation.object(i).polygon = setLMpolygon(x,y);
        
%         Npoints = length(annotation.object(i).polygon.pt);
%         for j = 1:Npoints
%             x=str2num(annotation.object(i).polygon.pt(j).x);
%             y=str2num(annotation.object(i).polygon.pt(j).y);
% 
%             x = round(x + Dx);
%             y = round(y + Dy);
% 
%             annotation.object(i).polygon.pt(j).x = num2str(x);
%             annotation.object(i).polygon.pt(j).y = num2str(y);
%         end
    end
end 
