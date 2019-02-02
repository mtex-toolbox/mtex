function [ebsd,rec,id] = selectInteractive(ebsd,varargin)
% select interactively a rectangular region of an EBSD data set
%
% Syntax
%   ebsd_small = selectInteractive(ebsd)
%   [ebsd_small,rec,id] = selectInteractive(ebsd)
%
% Input
%  ebsd - @EBSD
%
% Output
%  ebsd_small - @EBSD
%  rec - the rectangle
%  id  - id's of the selected data

disp('Use your mouse do drag a rectangle!')

ax = gca;

% no data cursor
datacursormode off

% nor any other interactions
try set(ax,'Interactions',[]); end
try ax.Interactions.Enabled = 'off'; end

waitforbuttonpress;
point1 = get(ax,'CurrentPoint');
rbbox; % dragg a rectangle

point2 = get(ax,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);            % extract x and y
point2 = point2(1,1:2);

rec = [min(point1,point2), abs(point1-point2)];
id = inpolygon(ebsd,rec);
ebsd = ebsd.subSet(id);

