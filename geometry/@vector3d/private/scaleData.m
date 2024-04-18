function [data,colorRange,minData,maxData] = scaleData(data,varargin)

data = real(data);

%if check_option(varargin,{'log','logarithmic'}), data(data==0)=NaN; end

% min and max
if check_option(varargin,{'log','logarithmic'})
  minData = min(data(~isnan(data) & ~isinf(log(data))));
else
  minData = min(data(~isnan(data) & ~isinf(data)));
end
maxData = max(data(~isnan(data) & ~isinf(data)));

% get color range from data
colorRange = [minData,maxData];
minData = min(data(:));
maxData = max(data(:));
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
   
elseif check_option(varargin,'colorRange','double')
  
  colorRange = get_option(varargin,'colorrange',[],'double');
  
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
