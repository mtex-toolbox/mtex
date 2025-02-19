function pixelPos = getPixelPos(hObj)

% Get the parent handle of the object (typically an axes)
hAx = ancestor(hObj, 'axes');

assert(~isempty(hAx),'The object has no axes as a parent.');

% Get the axes position in pixels (including space for titles, labels, etc.)
axPixelPos = getpixelposition(hAx);

% Consider the space reserved for titles, axis labels, etc.
tightInset = hAx.TightInset;  % [left, bottom, right, top] in normalized units

% Calculate the inner position of the axes (data area) in pixels
innerPixelPos = [
  axPixelPos(1) + tightInset(1) * axPixelPos(3),  % Left
  axPixelPos(2) + tightInset(2) * axPixelPos(4),  % Bottom
  axPixelPos(3) - (tightInset(1) + tightInset(3)) * axPixelPos(3),  % Width
  axPixelPos(4) - (tightInset(2) + tightInset(4)) * axPixelPos(4)   % Height
  ];

% Get the axis limits (data range)
xlim = hAx.XLim; ylim = hAx.YLim;

% Get the position of the object in data coordinates
objPosData = hObj.Position;

% Convert data coordinates to pixel coordinates (within the data area)
xPixel = innerPixelPos(1) + (objPosData(1) - xlim(1)) / (xlim(2) - xlim(1)) * innerPixelPos(3);
yPixel = innerPixelPos(2) + (objPosData(2) - ylim(1)) / (ylim(2) - ylim(1)) * innerPixelPos(4);
    
% Return the pixel position
pixelPos = [xPixel, yPixel];
end
