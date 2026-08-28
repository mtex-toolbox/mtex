function d = dspacing(v)
% distance between the lattice planes with normal v
%
% Syntax
%   d = dspacing(m)
%
% Input
%  m - @vector3d in a @crystalFrame
%
% Output
%  d - double, in the length unit of the lattice parameters
%
% See also
% crystalFrame isCrystalDirection

if ~isCrystalDirection(v)
  error('MTEX:vector3d:noCrystalDirection',...
    'A lattice spacing needs a direction given in a crystal frame.');
end

d = 1./norm(v);
