function Dlabelme = LOADINDEX;
% 
% load index from the toolbox folder

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LabelMe is a WEB-based image annotation tool and a Matlab toolbox that allows 
% researchers to label images and share the annotations with the rest of the community. 
%    Copyright (C) 2007  MIT, Computer Science and Artificial
%    Intelligence Laboratory. Antonio Torralba, Bryan Russell, William T. Freeman
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

toolboxfolder = strrep(which('UPDATEINDEX.m'), 'UPDATEINDEX.m', '');
load(fullfile(toolboxfolder, 'Dlabelme'));

disp(lastupdate)
