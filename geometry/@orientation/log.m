function v = log(ori,ori_ref)
%
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

if nargin == 1, ori_ref = ori.id; end

ori = project2FundamentalRegion(ori,ori_ref);

v = log(quaternion(ori),quaternion(ori_ref));
