function v = volume(ebsd,center,radius,varargin)
% ratio of orientations with a certain orientation
%
% Description
% returns the ratio of mass of the ebsd that is close to 
% one of the orientations as radius
%
% Syntax
%   v = volume(ebsd,center,radius,<options>)
%
% Input
%  ebsd   - @EBSD
%  center - @quaternion
%  radius - double
%
% See also
% ODF/volume

% extract weights
weight = get(ebsd,'weight');

% compute volume
if isempty(ebsd)
  v = 0;
else
  v = sum(weight(find(ebsd.orientations,center,radius,varargin{:})));
end
