function copyHoldState(fromAx,toAx)
% copy the hold state of one axes onto others
%
% Syntax
%   copyHoldState(mtexFig.gca,mtexFig.children)
%
% Description
% Propagates the hold state of |fromAx| to all axes in |toAx|. In contrast
% to <holdOn.html holdOn> this sets the *baseline* hold state, i.e. it is
% not undone when the calling function returns and it does not take part in
% the hold counter. Use it when a plot spans multiple axes and all of them
% should behave like the current one.
%
% Input
%  fromAx - source axes handle
%  toAx   - target axes handle(s)
%
% See also
% holdOn holdRelease getHoldState

fromAx = fromAx(isgraphics(fromAx,'axes'));
if isempty(fromAx), return; end
fromAx = fromAx(1);

toAx = toAx(isgraphics(toAx,'axes'));

nextPlot = fromAx.NextPlot;
holdStyle = getappdata(fromAx,'PlotHoldStyle');

for a = reshape(toAx,1,[])

  if a == fromAx, continue; end

  a.NextPlot = nextPlot;
  if isempty(holdStyle)
    if isappdata(a,'PlotHoldStyle'), rmappdata(a,'PlotHoldStyle'); end
  else
    setappdata(a,'PlotHoldStyle',holdStyle);
  end

end

end
