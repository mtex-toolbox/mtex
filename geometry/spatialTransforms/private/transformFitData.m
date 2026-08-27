function [dx,dy,w,x,y] = transformFitData(posA,posB,varargin)
% the displacement, the weights and the positions a transform fit works from
%
% Shared argument handling for every spatialTransform.fit, so they agree on
% what a measurement is: a point in frame A, where it went in frame B, and
% how much that measurement is worth. A tile that failed to correlate has
% no displacement to contribute and is dropped here rather than in each
% class - unweighted it would count as a confident zero.
%
% Syntax
%
%   [dx,dy,w,x,y] = transformFitData(posA,posB,'weights',peak)
%
% Input
%  posA, posB - @vector3d, the same points in the two frames
%
% Output
%  dx, dy - n × 1 displacement from posA to posB
%  w      - n × 1 weights, all ones if none were given
%  x, y   - n × 1 positions in frame A
%
% Options
%  weights - one per point
%
% See also
% spatialTransform robustLsq

assert(isa(posA,'vector3d') && isa(posB,'vector3d'),...
  'MTEX:spatialTransform:notAVector',...
  'A transform is fitted to two @vector3d point sets.');

assert(length(posA) == length(posB),'MTEX:spatialTransform:sizeMismatch',...
  'The two point sets have to be the same length, got %d and %d.',...
  length(posA),length(posB));

x = posA.x(:); y = posA.y(:);
dx = posB.x(:) - x; dy = posB.y(:) - y;

w = get_option(varargin,'weights');
if isempty(w), w = ones(size(x)); else, w = w(:); end

assert(numel(w) == numel(x),'MTEX:spatialTransform:weightSize',...
  'Expected %d weights, got %d.',numel(x),numel(w));

keep = isfinite(dx) & isfinite(dy) & isfinite(w) & isfinite(x) & isfinite(y);

assert(any(keep),'MTEX:spatialTransform:noData',...
  'Every measurement handed to the fit is missing or unweighted.');

dx = dx(keep); dy = dy(keep); w = w(keep); x = x(keep); y = y(keep);

end
