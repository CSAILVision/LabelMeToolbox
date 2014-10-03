function drawXML(filename, HOMEIMAGES)
%
% Shows the image and polygons corresponding to an XML file.
% drawXML(filename, HOMEIMAGES)
%
% filename   = name of the XML annotation file (full path name)
% HOMEIMAGES = root folder that contains the images
%
% Example:
%  filename = 'C:\atb\DATABASES\LabelMe\Annotations\05june05_static_indoor\p1010845.xml'
%  HOMEIMAGES = 'C:\atb\Databases\CSAILobjectsAndScenes\Images'
%  drawXML(filename, HOMEIMAGES)
%
% load annotation file:
v = loadXML(filename);

% load image
filename = fullfile(HOMEIMAGES, v.annotation.folder, v.annotation.filename);
filename = strrep(filename, '/', filesep);
filename = strrep(filename, '\', filesep);

img = imread(filename);

% define colors
colors = 'rgbcmy';

% draw image
figure; 
imshow(img); hold on

% draw each object (only non deleted ones)
Nobjects = length(v.annotation.object); n=0;
for i = 1:Nobjects
    if v.annotation.object(i).deleted == '0'
        n = n+1;
        class{n} = strtrim(v.annotation.object(i).name); % get object name
        X = str2num(char({v.annotation.object(i).polygon.pt.x})); % get X polygon coordinates
        Y = str2num(char({v.annotation.object(i).polygon.pt.y})); % get Y polygon coordinates

        plot([X; X(1)],[Y; Y(1)], 'LineWidth', 4, 'color', [0 0 0]); hold on
        h(n) = plot([X; X(1)],[Y; Y(1)], 'LineWidth', 2, 'color', colors(mod(n-1,6)+1)); hold on
    end
end
legend(h, class, 'location', 'best')

