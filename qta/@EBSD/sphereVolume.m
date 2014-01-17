function v = sphereVolume(ebsd,center,radius,varargin)
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

% extract orientations
o = ebsd.orientations;

% extract weights
weight = get(ebsd,'weight');

% compute volume
if isempty(ebsd)
  
  v = 0;

else
  
  center = orientation(center,o.CS);
  a = max(angle_outer(quaternion(o),quaternion(symmetrise(center))),[],2);
  
  v = sum(weight(a > pi - radius));
end
