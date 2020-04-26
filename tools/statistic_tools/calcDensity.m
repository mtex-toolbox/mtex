function [f,bandwidth] = calcDensity(x,varargin)
% kernel density estimation from real valued data
%
% Syntax
%   f = calcDensity(x)
%   f = calcDensity(x,'range',[xmin;xmax])
%
%   f = calcDensity([x,y],'range',[xmin,ymin;xmax,ymax])
%   f = calcDensity([x,y,z],'range',[xmin,ymin,zmin;xmax,ymax,zmax])
%
% Input
%  x,y,z - random samples as n x 1 vectors
% 
% Output
%  f - density as <https://de.mathworks.com/help/matlab/ref/griddedinterpolant.html griddedinterpolant>
%
% See also
% vector3d/calcDensity orientation/calcDensity

range = get_option(varargin,'range',[min(x);max(x)]);
varargin = delete_option(varargin,'range',1);

% the one dimensional case
if length(x) == numel(x)

  [bandwidth,density,grid] = kde(x,2^14,range(1),range(2),varargin{:});
  grid = {grid};
    
else % the multidimensional case
     
  dim = size(x,2);
  N = round(1000000^(1/dim));
  for d = 1:dim
    gs{d} = linspace(range(1,d),range(2,d),N);
  end
  
  [gs{:}] = ndgrid(gs{:});
  grid = gs;
  
  gs = cellfun(@(y) y(:),gs,'UniformOutput',false);    
  density = reshape(kdeN(x,[gs{:}]),size(grid{1}));
  
end

f = griddedInterpolant(grid{:},density,'spline');