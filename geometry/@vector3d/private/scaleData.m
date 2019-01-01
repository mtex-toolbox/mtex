function [data,colorRange,minData,maxData] = scaleData(data,varargin)

% min and max
minData = min(data(~isnan(data) & ~isinf(data)));
maxData = max(data(~isnan(data) & ~isinf(data)));

% log plot?
if check_option(varargin,{'log','logarithmic'})
  data = log10(data);
  data(imag(data) ~= 0 | isinf(data)) = nan;
end

% get colorrange from data
colorRange = [minData,maxData];
minData = nanmin(data(:));
maxData = nanmax(data(:));
if minData == maxData
  if minData == 0
    maxData = 1;
  else
    minData = 0;
  end
end

% from options
if check_option(varargin,{'contourf'},'double')
  
  contours = get_option(varargin,{'contourf','contour'},[],'double');
  colorRange = [contours(1),contours(end)];
  
  if check_option(varargin,{'log','logarithmic'})
    colorRange = log10(colorRange);
  end
  
elseif check_option(varargin,'colorRange','double')
  
  colorRange = get_option(varargin,'colorrange',[],'double');

  if check_option(varargin,{'log','logarithmic'})
    colorRange = log10(colorRange);
  end
  
  if isinf(colorRange(1)) 
    if isfinite(minData)
      colorRange(1) = minData;
    else
      colorRange(1) = colorRange(2)-2*eps;
    end
  end
  
end
 
% correct for allmost constant data
if isempty(colorRange) 
  colorRange = [0,1];
elseif colorRange(1)>0 && ...
    ((colorRange(2)-colorRange(1))/colorRange(1) < 1e-15)
  colorRange = [min(colorRange(1),0),max(colorRange(2),1)];
end
