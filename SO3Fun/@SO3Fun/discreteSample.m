function rot = discreteSample(SO3F,n,varargin)
% takes a random sample of n rotations from SO3Fun
%
% Syntax
%   rot = discreteSample(SO3F,n)
%
% Input
%  SO3F - @SO3Fun
%  n    - number of rotations
%
% Output
%  v -  @rotation / @orientation
%

res = get_option(varargin,'resolution',1.5*degree);

% take global random samples at grid points
SO3G = equispacedSO3Grid(SO3F.SRight,SO3F.SLeft,'resolution',res);
d = eval(SO3F,SO3G);

% take global random samples
d(d<0) = 0;   
rot = SO3G(discretesample(d,n));

% some local distortions
rot = rotation.rand(n,'maxAngle',res*1.5) .* rot(:);

% set antipodal if function is antipodal
if SO3F.antipodal == 1; rot.antipodal = 1; end

% if there is no crystal symmetry cast to rotation
if ~isa(SO3F.SLeft,'crystalSymmetry') && ~isa(SO3F.SRight,'crystalSymmetry')
  rot = rotation(rot);
else % random symmetry elements
  rot = rot .* SO3F.CS.rot(randi(SO3F.CS.numSym,length(rot),1));
  if SO3F.SS.numSym>1
    rot = SO3F.SS.rot(randi(SO3F.SS.numSym,length(rot),1)) .* rot;
  end
end
 
