function  [maxPhi1,maxPhi,maxPhi2] = getFundamentalRegion(cs,ss,varargin)
% get the fundamental region in Euler angles
%
% Syntax
%   [maxPhi1,maxPhi,maxPhi2] = getFundamentalRegion(cs,ss)
%
% Input
%  cs - crystal @symmetry
%  ss - specimen @symmetry
%
% Ouput
%  maxPhi1 - maximum Euler angle phi_1
%  maxPhi  - maximum Euler angle Phi
%  maxPhi2 - maximum Euler angle phi_2
%
% See also
% symmetry/getFundamentalRegionRodriguez symmetry/getFundamentalRegionPF

% phi1
if rotangle_max_y(cs) == pi && rotangle_max_y(ss) == pi
  maxPhi1 = pi/2;
else
  maxPhi1 = rotangle_max_z(ss);
end

%phi2
maxPhi2 = rotangle_max_z(cs);

% Phi
maxPhi = min(rotangle_max_y(cs),rotangle_max_y(ss))/2;
if check_option(varargin,'complete')
  maxPhi1 = 2*pi;
  maxPhi = pi;
  maxPhi2 = 2*pi;
end
%elseif check_option(varargin,'antipodal')
%  if rotangle_max_y(cs)/2 < pi
%    max_phi2 = max_phi2 / 2;
%end

if check_option(varargin,'SO3Grid') && strcmp(Laue(cs),'m-3m')  
  maxPhi = pi/3;
end
