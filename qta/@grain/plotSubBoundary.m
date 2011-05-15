function plotSubBoundary(grains,varargin)
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
   
    h = plot(polygon(pl),varargin{:});
    
  elseif ispolyeder(grains)
     
    h = plot(polyeder(pl),'FaceColor','r',varargin{:});
  end
  
  optiondraw(h,varargin{:});
else
  return
end


