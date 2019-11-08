function simulateClick(x,y,ax)
% simulate a click in the active axis
%
% Syntax
%   simulateClick(x,y)
%
% Input
%  x,y - coordinates in the current axis
%

if nargin==2, ax = gca; end
fig = get(ax,'parent');

% convert to figure pixel
[figX,figY] = ds2nfu(x,y);

figPos = get(fig,'Position');

screenSize = get(0,'ScreenSize');

monX = figX + figPos(1);
monY = screenSize(end) - (figY + figPos(2));

% bring current figure in front
figure(fig)

% and do the click
import java.awt.Robot;
import java.awt.event.*;
mouse = Robot;
mouse.mouseMove(monX, monY);
mouse.mousePress(InputEvent.BUTTON1_MASK);    %left click press
mouse.mouseRelease(InputEvent.BUTTON1_MASK);   %left click release

%res = get(ax,'CurrentPoint');
%xnum2str(res(1,1))
%xnum2str(res(1,2))
