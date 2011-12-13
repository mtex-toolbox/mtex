function plot( grains, varargin )




if check_option(varargin,'boundary')
  plotBoundary(grains,varargin{:})
else
  plotGrains(grains,varargin{:})
end
