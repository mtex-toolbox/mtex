function  l = segLength(gB,varargin)
% length of boundary segments in µm
%
% Input
%  gb - @grainBoundary
%
% Output
%  l - length of the boundary segments in µm
%

if nargin == 2
  l = norm(gB.allV(gB.F(varargin{1},1)) - gB.allV(gB.F(varargin{1},2)));
else
  l = norm(gB.allV(gB.F(:,1)) - gB.allV(gB.F(:,2)));
end
