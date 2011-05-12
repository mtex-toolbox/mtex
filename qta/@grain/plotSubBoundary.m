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
  
  if ispolygon(grains)
    frs = [grains(b).subfractions];

    X = [frs.xx];
    Y = [frs.yy];

    X = [X ; NaN(1,size(X,2))];
    Y = [Y ; NaN(1,size(Y,2))];

    [X,Y,lx,ly] = fixMTEXscreencoordinates(X,Y,varargin{:});

    h = plot(X(:),Y(:),varargin{:});

    xlabel(lx); ylabel(ly);  
    fixMTEXplot;
  elseif ispolyeder(grains)
    
    sub = [grains(b).subfractions];   
    h = plot(polyeder([sub.P]),'fill');
  end
  
  optiondraw(h,varargin{:});
else
  return
end


