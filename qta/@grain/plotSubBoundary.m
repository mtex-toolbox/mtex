function varargout = plotSubBoundary(grains,varargin)
% plot the grain boundaries
%
%% Syntax
%  plotSubBoundary(grains)  -
%  plotSubBoundary(grains,LineSpec,...) -
%  plotSubBoundary(grains,'PropertyName',PropertyValue,...) -
%
%% Input
%  grains - @grain
%
%% See also
% grain/plot grain/plotellipse grain/plotgrains grain/plotBoundary
%

b = hasSubBoundary(grains);

if any(b)
  newMTEXplot;
  
  fractions = [grains(b).subfractions];
  pl = [fractions.P];
  
  if ispolygon(grains)
    
    [h,po] = plot(polygon(pl),varargin{:});
    
  elseif ispolyeder(grains)
    
    [h,po] = plot(polyeder(pl),'FaceColor','r',varargin{:});
  end
  
  optiondraw(h,varargin{:});
  
  if nargout > 0
    varargout{1} = h;
  end
  if nargout > 1
    varargout{2} = po;
  end
else
  return
end


