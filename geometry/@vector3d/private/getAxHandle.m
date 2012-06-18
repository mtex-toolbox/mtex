function [ax,v,varargin] = getAxHandle(v,varargin)


if ishandle(v)
  
  if isa(handle(v),'axes')
    ax = v;
  else % new plot
    
    ax = gca;
    
    m = 0.025;
    set(ax,'units','normalized','position',[0+m 0+m 1-2*m 1-2*m]);
    
  end
  
  v = varargin{1};
  varargin(1) = [];
  
else
  
  ax = gca;
  
end

