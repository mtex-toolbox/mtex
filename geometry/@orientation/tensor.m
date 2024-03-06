function t = tensor(ori)
% tensor of an orientation or misorientation
%
% Syntax
%   t = tensor(ori)
%
% Input
%  ori - @orientation
%
% Output
%  mat - @tensor
%
% See also
% mat2quat Euler axis2quat hr2quat

t = tensor(matrix(ori),'rank',2);

if isa(ori.CS,'crystalSymmetry') && isa(ori.SS,'crystalSymmetry') && ...
    ori.CS ~= ori.SS

  ref1 = [ori.CS.aAxis, ori.CS.bAxis, ori.CS.cAxis];
  M1 = tensor(ref1.xyz);

  ref2 = [ori.SS.aAxis, ori.SS.bAxis, ori.SS.cAxis];
  M2 = tensor(ref2.xyz);

  t = inv(M2) * t * M1; %#ok<MINV>

end
