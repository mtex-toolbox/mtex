function v = fibreVolume(ebsd,h,r,radius,varargin)
% ratio of orientations close to a certain fibre
%
% Description
% returns the ratio of mass of the ebsd that is close to 
% a certain fibre
%
% Syntax
%   v = volume(ebsd,h,r,radius)
%
% Input
%  ebsd   - @EBSD
%  h      - @Miller
%  r      - @vector3d
%  radius - double
%
% See also
% ODF/volume

% extract orientations
o = ebsd.orientations;

% check input
argin_check(h,{'Miller','vector3d'});
if isa(h,'Miller')
  h = ensureCS(o.CS,{h});
else
  h = Miller(h,o.CS);
end
argin_check(r,'vector3d');
argin_check(radius,'double');

% extract weights
weight = get(ebsd,'weight');

% compute volume
if isempty(o)
  v = 0;
else
  v = sum(weight(angle(o .\ r,h,varargin{:}) < radius));
end
