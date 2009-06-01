function plotsubfractions(grains,varargin)
% plot the grain boundaries
%
%% Syntax
%  plotsubfractions(grains)
%  plotsubfractions(grains,LineSpec,...)
%  plotsubfractions(grains,'PropertyName',PropertyValue,...)
%
%% Input
%  grains - @grain
%
%% See also
% grain/plot grain/plotellipse grain/plotgrains
%
  
b = hassubfraction(grains);

if any(b) 
  newMTEXplot;
  
  frs = [grains(b).subfractions];

  X = [frs.xx];
  Y = [frs.yy];
    
  X = [X ; NaN(1,size(X,2))];
  Y = [Y ; NaN(1,size(Y,2))];

  [X,Y,lx,ly] = fixMTEXscreencoordinates(X,Y,varargin); 
 
  plot(X(:),Y(:),varargin{:});
  
  prepareMTEXplot;
  xlabel(lx); ylabel(ly);  
  fixMTEXplot;
else
  return
end


