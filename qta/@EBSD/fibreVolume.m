function v = fibreVolume(ebsd,h,r,radius,varargin)
% ratio of orientations close to a certain fibre
%
%% Description
% returns the ratio of mass of the ebsd that is close to 
% a certain fibre
%
%% Syntax
%  v = volume(ebsd,h,r,radius,<options>)
%
%% Input
%  ebsd   - @EBSD
%  h      - @Miller
%  r      - @vector3d
%  radius - double
%
%% See also
% ODF/volume

%% extract orientations
o = get(ebsd,'orientations');

%% check input
argin_check(h,{'Miller','vector3d'});
if isa(h,'Miller')
  h = ensureCS(get(o,'CS'),{h});
else
  h = Miller(h,get(o,'CS'));
end
argin_check(r,'vector3d');
argin_check(radius,'double');

if ~strcmp(Laue(get(o,'SS')),'-1')
  error('Only triclinic specimen symmetry is supported for fibreVolume');
end

%% extract weights
weight = get(ebsd,'weight');

%% compute volume
if isempty(o)
  v = 0;
else
  v = sum(weight(angle(o .\ r,h,varargin{:}) < radius));
end
