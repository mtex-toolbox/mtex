function v = sphereVolume(ebsd,center,radius,varargin)
% ratio of orientations with a certain orientation
%
%% Description
% returns the ratio of mass of the ebsd that is close to 
% one of the orientations as radius
%
%% Syntax
%  v = volume(ebsd,center,radius,<options>)
%
%% Input
%  ebsd   - @EBSD
%  center - @quaternion
%  radius - double
%
%% See also
% ODF/volume

% extract orientations
o = get(ebsd,'orientations');

% extract weights
weight = get(ebsd,'weight');

% compute volume
if isempty(o)
  v = 0;
else
  
  center = orientation(center,get(o,'CS'),get(o,'SS'));
  a = max(angle_outer(quaternion(o),symmetrise(center)),[],2);
  
  v = sum(weight(a > pi - radius));
end
