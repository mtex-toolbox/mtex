function screenExtent = getScreenExtent
% the screen extent figure sizes are derived from
%
% Figure sizes are a fraction of the screen, so by default every rendered
% figure depends on the monitor MTEX happens to be running on. Setting the
% MTEX preference |screenSize| to a fixed |[width height]| in pixel pins
% them to a virtual screen of that size instead, which makes figure exports
% reproducible across machines - see the documentation build in the mtex
% homepage repository.
%
% It is also the size a figure may not exceed, so pin it to the area a window
% actually has rather than to the monitor: a figure the screen cannot hold is
% one the window manager shrinks, and a snapshot taken of that squeezes the
% figure into the wrong shape. The room a title bar and a task bar take belongs
% here, not in the layout.
%
% Syntax
%   screenExtent = getScreenExtent
%
% Output
%  screenExtent - as <matlab:doc('root') MonitorPositions>, one row per monitor
%
% See also
% mtexFigure/drawNow

screenSize = getMTEXpref('screenSize');

if isempty(screenSize)
  screenExtent = get(0,'MonitorPositions');
else
  screenExtent = [1 1 screenSize(1) screenSize(2)];
end

end
