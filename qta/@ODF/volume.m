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
% ODF/fibrevolume ODF/entropy ODF/textureindex

% check input
argin_check(center,'quaternion');
argin_check(radius,'double');

% get resolution (for slow algorithm)
res = get_option(varargin,'RESOLUTION',min(1.25*degree,radius/30),'double');

% if radius is to large -> slow algorithm
if radius > rotangle_max_z(odf(1).CS)/2 || length(odf(1).SS) > 1
  v = slowVolume(odf,center,radius,res,[],varargin{:});
  return
end


v = 0;
S3G = [];
% cycle through components
for i = 1:length(odf)
  
  if check_option(odf(i),'UNIFORM') % uniform portion
    
    v = v + odf(i).c * length(odf(1).CS) * (radius - sin(radius))./pi;
  
  elseif check_option(varargin,'FOURIER') || check_option(odf(i),'FOURIER') 
    
    [vv,S3G] = slowVolume(odf(i),center,radius,res,S3G);
    v = v + vv;
    
  elseif check_option(odf(i),'FIBRE') % fibre symmetric portion
     
    [vv,S3G] = slowVolume(odf(i),center,radius,res,S3G);
    v = v + vv;
    
  elseif check_option(odf(i),'BINGHAM') % Bingham portion
     
    [vv,S3G] = slowVolume(odf(i),center,radius,res,S3G);
    v = v + vv;
    
  else % radially symmetric portion
      
    v = v + fastVolume(odf(i),center,radius);
    
  end
end



function [v,S3G] = slowVolume(odf,center,radius,res,S3G,varargin)

% discretisation
if nargin < 5 || isempty(S3G)
  S3G = SO3Grid(res,odf(1).CS,odf(1).SS,'MAX_ANGLE',radius,'center',center,varargin{:});
end

% estimate volume portion of odf space
reference = 9897129 * 96 / length(odf(1).CS) / length(odf(1).SS);
f = min(1,numel(S3G) * (res / 0.25 / degree)^3 / reference);
  
% eval odf
if f==0
  v = 0;
else
  v = mean(eval(odf,S3G)) * f;  %#ok<EVLC>
  v = min(v,sum(getweights(odf)));
end

function v = fastVolume(odf,center,radius)

% compute distances
d = reshape(angle_outer(center,odf.center,'all'),numel(odf.center),[]);

% precompute volumes
[vol,r] = volume(odf.psi,radius);

% interpolate
v = interp1(r,vol,d,'spline');

% sum up
v = sum(v.' * odf.c(:));

