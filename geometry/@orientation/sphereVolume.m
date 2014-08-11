function v = sphereVolume(ori,center,radius,varargin)
% ratio of orientations with a certain orientation
%
% Description
% returns the ratio of mass of the ebsd that is close to 
% one of the orientations as radius
%
% Syntax
%   v = volume(ebsd,center,radius)
%
% Input
%  ebsd   - @EBSD
%  center - @quaternion
%  radius - double
%
% See also
% ODF/volume

% compute volume
if isempty(ori)
  
  v = 0;

else
  
  center = orientation(center,ori.CS);
  a = max(angle_outer(quaternion(ori),quaternion(symmetrise(center))),[],2);
  
  v = sum(ori.weights(a > pi - radius));
end
