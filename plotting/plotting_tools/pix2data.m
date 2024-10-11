function [dx,dy] = pix2data(ax,pix)

% Get the axes position in pixels (including space for titles, labels, etc.)
axPixelPos = getpixelposition(ax);

% Consider the space reserved for titles, axis labels, etc.
tightInset = ax.TightInset;  % [left, bottom, right, top] in normalized units

if ax.Units == "pixels"
  width = axPixelPos(3) - tightInset(1) - tightInset(3);
  height = axPixelPos(4) - tightInset(2) - tightInset(4);
else
  width = (1 - tightInset(1) - tightInset(3)) * axPixelPos(3);
  height = (1 - tightInset(2) - tightInset(4)) * axPixelPos(4);
end

dx = diff(ax.XLim) / width;
dy = diff(ax.YLim) / height;

if nargin == 2, dx = dx * pix; dy = dy*pix; end

end
