function plot(grains,varargin)
% bypasses to the Grain plotting routines
%
% Input
%  grains - @GrainSet
%
% Flags
%  boundary  - plot the grain boundary as done by [[GrainSet.plotBoundary.html, plotBoundary]]
%
% See also
% GrainSet/plotBoundary Grain2d/plotGrains Grain3d/plotGrains

% plot boundary
if check_option(varargin,'boundary')
  
  plotBoundary(grains,varargin{:})
  
% plot filled grains
else
  
  plotGrains(grains,varargin{:});
  
end
