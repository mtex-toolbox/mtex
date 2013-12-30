function [ori,omega] = project2FundamentalRegion(ori,ori_ref)
% projects orientation to a fundamental region
%
%% Syntax
%
% [ori,omega] = project2FundamentalRegion(ori,rot_ref)
%
%% Input
%  ori     - @orientation
%  ori_ref - reference @rotation
%
%% Output
%  ori     - @orientation
%  omega   - rotational angle to reference rotation
%

if nargin == 2 && ~isempty(ori_ref)
  [ori.rotation,omega] = project2FundamentalRegion(ori.rotation,ori.CS,quaternion(ori_ref));
else
  [ori.rotation,omega] = project2FundamentalRegion(ori.rotation,ori.CS,ori.SS);
end
