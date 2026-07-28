function r = inversion(varargin)
% the inversion
%
% Description
% The improper rotation that maps every vector onto its negative. It is
% the identical rotation combined with the inversion, hence
% <rotation.isImproper.html |isImproper|> returns true.
%
% Syntax
%   rot = rotation.inversion
%   rot = rotation.inversion(5)
%
% Input
%  n,m - size of the array of rotations
%
% Output
%  rot - @rotation
%
% See also
% rotation/id rotation/isImproper

r = -rotation.id(varargin{:});
