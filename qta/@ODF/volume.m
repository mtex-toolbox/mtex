function v = volume(odf,center,radius,varargin)
% ratio of orientations with a certain orientation
%
%% Description
% returns the ratio of mass of the odf with that is close to 
% one of the orientations as radius
%
%% Syntax
%  v = volume(odf,center,radius,<options>)
%
%% Input
%  odf    - @ODF
%  center - @quaternion
%  radius - double
%
%% Options
%  resolution - resolution of discretization
%
%% See also
% ODF/entropy ODF/textureindex

argin_check(center,'quaternion');
argin_check(radius,'double');

% get resolution
res = get_option(varargin,'RESOLUTION',min(2.5*degree,radius/10),'double');

% discretisation
S3G = center*SO3Grid(res,odf(1).CS,odf(1).SS,'MAX_ANGLE',radius);

% estimate volume portion of odf space
if radius < rotangle_max_z(odf(1).CS) / 2
  % theoretical value
  f = length(odf(1).CS)*(radius - sin(radius))/pi;
else
  % numerical value
  f = GridLength(SO3Grid(2.5*degree,odf(1).CS,odf(1).SS,'MAX_ANGLE',radius))/...
    GridLength(SO3Grid(2.5*degree,odf(1).CS,odf(1).SS));
end

% eval odf
if f==0
  v = 0;
else
  v = sum(eval(odf,S3G))/GridLength(S3G)*f;
end

