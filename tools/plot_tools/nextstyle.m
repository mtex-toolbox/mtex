function [l,c,m] = nextstyle(ax,autoColor,autoStyle,firsttime)
%NEXTSTYLE Get next plot linespec
%   [L,C,M] = NEXTSTYLE(AX) gets the next line style, color
%   and marker for plotting from the ColorOrder and LineStyleOrder
%   of axes AX.
%
%   See also PLOT, HOLD

%   [L,C,M] = NEXTSTYLE(AX,COLOR,STYLE,FIRST) gets the next line
%   style and color and increments the color index if COLOR is true
%   and the line style index if STYLE is true. If FIRST is true
%   then start the cycling from the start of the order unless HOLD
%   ALL is active.

%   Copyright 1984-2003 The MathWorks, Inc. 

if nargin == 1
  autoColor = true;
  autoStyle = true;
  firsttime = false;
end

co = get(ax,'ColorOrder');
lo = get(ax,'LineStyleOrder');

ci = [1 1];
if (isappdata(ax,'PlotHoldStyle') && getappdata(ax,'PlotHoldStyle')) || ...
      ~firsttime
  if isappdata(ax,'PlotColorIndex')
    ci(1) = getappdata(ax,'PlotColorIndex');
  end
  if isappdata(ax,'PlotLineStyleIndex')
    ci(2) = getappdata(ax,'PlotLineStyleIndex');
  end
end

cm = size(co,1);
lm = size(lo,1);

if isa(lo,'cell')
  [l,c,m] = colstyle(lo{mod(ci(2)-1,lm)+1});
else
  [l,c,m] = colstyle(lo(mod(ci(2)-1,lm)+1));
end
c = co(mod(ci(1)-1,cm)+1,:);

if autoStyle && (ci(1) == cm)
  ci(2) = mod(ci(2),lm) + 1;
end
if autoColor
  ci(1) = mod(ci(1),cm) + 1;
end
setappdata(ax,'PlotColorIndex',ci(1));
setappdata(ax,'PlotLineStyleIndex',ci(2));

if isempty(l) && ~isempty(m)
  l = 'none';
end
if ~isempty(l) && isempty(m)
  m = 'none';
end
