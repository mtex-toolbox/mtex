function plot(T,varargin)
% plot a tensor
%
% Syntax
%   plot(T)
%   plot(T,'3d')
%
% Input
%  T - @tensor
%
% Options
%  3d   - colored 3d plot on the sphere
%  surf - colored 3d surface plot
%  contour  - contour lines
%  contourf - filled contours 
% 
% See also
%

plot(T.directionalMagnitude,varargin{:})
