function v = log(ori,ori_ref)
% the inverse of the exponential map
%
% Syntax
%   v = log(ori)
%   v = log(ori,ori_ref)
%
% Input
%  ori - @orientation
%  ori_ref - @orientation
%
% Output
%  v - @vector3d
%
% See also
% 

if nargin == 2

  if isa(ori.CS,'crystalSymmetry')
    ori = inv(ori_ref) .* ori;
  else
    ori = ori .* inv(ori_ref);
  end
    
end
  
ori = project2FundamentalRegion(ori);

v = log@quaternion(ori);
