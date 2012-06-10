function [data,colorRange] = scaleData(data,varargin)

% log plot?
if check_option(varargin,{'log','logarithmic'})
  data = log10(data);
  data(imag(data) ~= 0 | isinf(data)) = nan;
end

% get colorrange from data
colorRange = [nanmin(data(:)),nanmax(data(:))];

% from options
if check_option(varargin,'colorRange','double')
  
  colorRange = get_option(varargin,'colorrange',[],'double');

  if check_option(varargin,{'log','logarithmic'})
    colorRange = log10(colorRange);
  end
  
end
 
% correct for allmost constant data
if colorRange(2)-colorRange(1) < 1e-15
  colorRange = [min(colorRange(1),0),max(colorRange(2),1)];
end
