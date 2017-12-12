function v = log(ori,ori_ref,varargin)
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

if nargin > 2 && check_option(varargin,'ll')
  ori_ref = orientation(ori_ref,ori.CS,ori.SS);
  v = axis(ori,ori_ref) .* angle(ori,ori_ref);
  return
end

if nargin >= 2

  if isa(ori.CS,'crystalSymmetry')
    ori = inv(ori_ref) .* ori;
    % we should not change the reference frame of the reference
    % orientation
    ori.SS = specimenSymmetry;
  else    
    ori = ori .* inv(ori_ref);
    % we should not change the reference frame of the reference
    % orientation
    ori.CS = specimenSymmetry;
  end
    
end

ori = project2FundamentalRegion(ori);

v = log@quaternion(ori);

if nargin>2 && check_option(varargin,'left')
  v = rotation(ori_ref) .* v;
end