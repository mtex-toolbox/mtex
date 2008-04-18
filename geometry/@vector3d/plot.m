function plot(v,varargin)
% plot three dimensional vector

if length(v) > 20 || check_option(varargin,'data')    

  plot(S2Grid(v),varargin{:},'color','k');
  
else
    
  s = cell(1,numel(v));
  for i = 1:numel(v)
    s{i} = char(subsref(v,i),'latex');
  end
  plot(S2Grid(v),'data',s,varargin{:},'color','k');

end
