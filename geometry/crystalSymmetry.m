function cF = crystalSymmetry(varargin)
% the crystal reference frame of a phase, carrying its point group
%
% Since <crystalFrame.crystalFrame.html |crystalFrame|> carries the point
% group (ADR 0008), a crystal symmetry *is* a crystal frame - this is the
% constructor that names it the way crystallography does. It returns a
% @crystalFrame.
%
% Syntax
%   crystalSymmetry('cubic')
%   crystalSymmetry('2/m',[8.6 13 7.2],[90 116, 90]*degree,'mineral','orthoclase')
%   crystalSymmetry('O')
%   crystalSymmetry(cF)  % the trivial group carrying the crystalFrame cF
%   crystalSymmetry('LaueId',9)
%   crystalSymmetry('SpaceId',153)
%   rot = rotation.map(vector3d(1,1,1),vector3d.Z,vector3d(0,-1,1),vector3d.X)
%   crystalSymmetry('432','rotAxes',rot)
%
% Input
%  name  - Schoenflies or International notation of the point group
%  axes  - [a,b,c] - length of the crystallographic axes
%  angle - [alpha,beta,gamma] - angle between the axes
%
% Options
%  X||a*, Z||c - default alignment of the Cartesian to the crystal axes
%  X||a, Z||c* - other alignments
%  EDAX        - the alignment convention used by EDAX / TSL / OIM
%
% Output
%  cF - @crystalFrame
%
% See also
% crystalFrame specimenSymmetry symmetry

% every way of naming a crystal frame lives in the constructor of
% <crystalFrame.crystalFrame.html |crystalFrame|> now
if nargin == 0
  cF = crystalFrame('1');
else
  cF = crystalFrame(varargin{:});
end

end
