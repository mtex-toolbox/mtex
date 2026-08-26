function side = cBarSideOf(h,fallback)
% which side a colorbar was asked for, and put its ticks on the outside
%
% Input
%  h        - colorbar handle
%  fallback - side to keep if the Location says nothing
%
% Description
% MATLAB has two Locations per side: 'south' puts the bar inside the axes,
% 'southoutside' beside it. mtexFigure places every bar it owns outside, so
% the two mean the same thing here - what matters is that both name a side.
% Reading only the 'outside' ones left 'location','south' with the default
% side, and a horizontal bar was then rebuilt as a vertical one on the east.
%
% 'manual' says nothing: assigning a Position sets it, so a bar that has been
% through the layout once reports that and nothing else.
%
% See also
% adoptColorbars mtexFigure/colorbar

side = fallback;

loc = char(h.Location);
if any(strcmp(loc,{'manual','none'})), return; end

loc = erase(loc,'outside');
if ~any(strcmp(loc,{'north','south','east','west'})), return; end

side = loc;

% mtexFigure puts every bar it owns beside the axes, so the ticks belong on
% the far side of it. An inside Location draws them inward, which for
% 'location','south' put the numbers on top of the plot.
set(h,'AxisLocation','out');

end
