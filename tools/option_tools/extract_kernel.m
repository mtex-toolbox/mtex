function [k, hw, options]= extract_kernel(g,varargin)


if nargin == 2, 
  varargin = varargin{:}; 
  if ~iscell(varargin)
    varargin = {varargin};
  end
end

k = get_option(varargin,'kernel',[],'kernel');

if isempty(k), 
  hw = get_option(varargin,'halfwidth');
  if isempty(hw), 
    [a, b] = mean(g);
    hw = max(prod(1-b) ,2*degree);
  end
  %  if isempty(hw), hw = max(get(g,'resolution') * 3,2*degree); end
  k = deLaValeePoussinKernel('halfwidth',hw);
else
  hw = gethw(k);
end

if nargout > 2, 
  res = get_option(varargin,'resolution',max(0.75*degree,hw / 2));
  options = set_option(varargin,'kernel',k,'RESOLUTION',res); 
end
