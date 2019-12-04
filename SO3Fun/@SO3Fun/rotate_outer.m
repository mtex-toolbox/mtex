function SO3F = rotate_outer(SO3F,rot,varargin)
% rotate ODF
%
% Syntax

%
% Input
%  odf - @ODF
%  q   - @rotation
%
% Output
%  rotated odf - @ODF

SO3F = SO3FunHandle(@(x) SO3F.eval(inv(rot) .* x));