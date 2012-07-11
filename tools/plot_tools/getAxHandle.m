function [ax,v,varargin] = getAxHandle(v,varargin)


if ishandle(v)
  
  if isa(handle(v),'axes')
    ax = v;
  else
    ax = gca;
  end
  
  v = varargin{1};
  varargin(1) = [];
  
else
  
  ax = gca;
  
end

