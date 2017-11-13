function v = axis(bM,varargin)
% misorientation axis
%
% Syntax
%   v = axis(bM)
%
% Input
%  bM - @boundaryMisorientation
%
% Output
%  v - @vector3d

v = bM.mori.axis;
