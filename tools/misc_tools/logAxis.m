function logAxis(ax,xLimits,yLimits)

if nargin == 0, ax = gca; end
set(ax,'XScale','log','YScale','log');

if (nargin < 2) || isempty(xLimits), xLimits = get(ax,'XLim'); end
  
if (nargin < 3) || isempty(yLimits), yLimits = get(ax,'YLim'); end

logScale = diff(yLimits)/diff(xLimits);
powerScale = diff(log10(yLimits))/diff(log10(xLimits));

set(ax,'Xlim',xLimits,...
  'YLim',yLimits,...
  'DataAspectRatio',[1 logScale/powerScale 1]);

end

