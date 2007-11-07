function plot(v,varargin)
% plot vector

if length(v) > 20

  plot(S2Grid(v),varargin{:});
  
else

  if ~check_option(varargin,'data')    
    
    s = cell(1,numel(v));
    for i = 1:numel(v)
      s{i} = char(subsref(v,i),'latex');
    end
    plot(S2Grid(v),'data',s,varargin{:});
    
  else
    
    plot(S2Grid(v),varargin{:});
    
  end    
end
