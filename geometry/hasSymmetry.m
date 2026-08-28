function out = hasSymmetry(v)
% whether the frame something is expressed in carries a point group
%
% A direction in a frame whose group is more than the identity stands for
% its whole symmetrically equivalent set - that is what makes |symmetrise|,
% |unique|, |dot| and |mean| work up to symmetry. A spherical function in
% such a frame is symmetric under the group in the same sense. The group on
% the frame decides it, so a specimen frame carrying a sample symmetry
% counts exactly as a crystal frame does (ADR 0008).
%
% Syntax
%   out = hasSymmetry(v)
%
% Input
%  v - anything
%
% Output
%  out - logical
%
% Example
%
%   cs = crystalSymmetry('m-3m',[4.05 4.05 4.05]);
%   hasSymmetry(Miller(1,0,0,cs))
%   hasSymmetry(xvector)
%
% See also
% isCrystalDirection referenceFrame vector3d/symmetrise

out = (isa(v,'vector3d') || isa(v,'S2Fun')) && ...
  ~isempty(v.frame) && v.frame.id ~= 1;

end
