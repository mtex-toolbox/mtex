function [v,vAntipodal,swap,minRho] = project2FundamentalRegion(v,sym,varargin)
% projects vectors to the fundamental region of the inverse pole figure
%
% Input
%  v  - @vector3d
%  cs - @symmetry
%
% Options
%  CENTER - reference orientation
%  antipodal  - include [[AxialDirectional.html,antipodal symmetry]]
%
% Output
%  v     polar( - @vector3d
%  swap   - .....
%  minRho - begin of Fundamental region

% get fundamental region

% this is needed sometimes to get the right function to be called
if iscell(sym), sym = sym{1};end

[q,rho_rot] = rotation_special(sym);
% q       - rotations not about the z -axis
% rho_rot - position of the mirroring plane

[minTheta,maxTheta,minRho,maxRho] = sym.getFundamentalRegionPF(varargin{:}); %#ok<ASGLU>

% symmetrise
sv = q * v;
[theta,rho] = polar(sv);

% if possible swap to upper hemisphere
if ~isempty(rho_rot)
  ind = theta > pi/2;
  theta(ind) = pi - theta(ind);
  rho(ind) = 2*rho_rot - rho(ind);
end

% find element with minimal theta, rho angles

% compute rho within the range [rho_min,rho_max]
rho = modCentered(rho,rotangle_max_z(sym),minRho);

d1 = rho + 1000*theta;
[d1,th1,rh1] = selectMinbyColumn(d1,theta,rho);

v = sph2vec(th1,rh1);

% apply inversion
if ~isempty(rho_rot)
  rho2 = modCentered(pi+2*rho_rot - rho,rotangle_max_z(sym),minRho);
  theta2 = theta;
elseif check_option(varargin,'antipodal') || v.antipodal
  rho2 = modCentered(pi + rho,rotangle_max_z(sym),minRho);
  theta2 = pi - theta;    
else
  rho2 = rho;
  theta2 = pi - theta;
end

d2 = rho2 + 1000*theta2;
[d2,th2,rh2] = selectMinbyColumn(d2,theta2,rho2);

% antipodal
if check_option(varargin,'antipodal') || v.antipodal
  swap = false(length(v),1);
else
  swap = d1 > d2;
end

[tmp,theta,rho] = selectMinbyColumn([d1;d2],[th1;th2],[rh1;rh2]);
vAntipodal = sph2vec(theta,rho);

% ----------------------------------------------------------------
function d = modCentered(a,b,c)

d = mod(a-c,b)+c;
