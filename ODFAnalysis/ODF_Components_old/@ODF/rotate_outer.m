function odf = rotate_outer(odf,rot,varargin)
% rotate ODF
%
% Input
%  odf - @ODF
%  rot - @rotation
%
% Output
%  rotated odf - @ODF

odf = rotate(odf,rot,varargin{:});