function [x,y,z] = getLMpolygon3D(polygon)
%
% Utility function that gives the coordinates of the polygon's vertices

x = str2num(char({polygon.pt.x})); % get X polygon coordinates
y = str2num(char({polygon.pt.y})); % get Y polygon coordinates
z = str2num(char({polygon.pt.z})); % get Y polygon coordinates

