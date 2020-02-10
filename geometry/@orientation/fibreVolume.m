function v = fibreVolume(ori,h,r,radius,varargin)
% ratio of orientations close to a certain fibre
%
% Description
% returns the ratio of mass of the ebsd that is close to 
% a certain fibre
%
% Syntax
%   v = volume(ori,h,r,radius)
%
% Input
%  ori    - @orientation
%  h      - @Miller
%  r      - @vector3d
%  radius - double
%
% See also
% ODF/volume

% check input
argin_check(h,{'Miller','vector3d'});
if isa(h,'Miller')
  h = ori.CS.ensureCS(h);
else
  h = Miller(h,ori.CS);
end
argin_check(r,'vector3d');
argin_check(radius,'double');

% compute volume
if isempty(ori)
  v = 0;
elseif check_option(varargin,'weight')
  weights = get_option(varargin,'weights');
  v = sum(weights(angle(ori .\ r,h,varargin{:}) < radius)) / sum(weights(:));
else
  v = nnz(angle(ori .\ r,h,varargin{:}) < radius) ./ length(ori);
end
