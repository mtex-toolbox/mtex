function [v,swap,rot] = project2FundamentalRegion(v,sym,varargin)
% projects orientations to a fundamental region
%
%% Input
%  v  - @vector3d
%  cs - @symmetry
%
%% Options
%  CENTER - reference orientation
%  antipodal  - include [[AxialDirectional.html,antipodal symmetry]]
%
%% Output
%  v  - @vector3d
%  dist - distance

[q,rho_rot] = rotation_special(sym);

if ~isempty(strmatch(Laue(sym),{'-3','-3m'})) && ...
    vector3d(Miller(1,0,0,sym)) == -yvector
  rot = 30*degree;
else
  rot = 0;
end

% symmetrise
sv = q * v;
[theta,rho] = vec2sph(sv);

% if possible swap to upper hemisphere
if ~isempty(rho_rot)
  ind = theta > pi/2;
  theta(ind) = pi - theta(ind);
  rho(ind) = 2*rho_rot - rho(ind);
end

% find element with minimal theta, rho angles
rho = modCentered(rho,rotangle_max_z(sym),rot);
%d1 = pi/2 + rho + 1000*theta;
d1 = rho + 1000*theta;
[d1,th1,rh1] = selectMinbyColumn(d1,theta,rho);

% apply inversion
if ~isempty(rho_rot)
  rho2 = modCentered(2*rho_rot - rho,rotangle_max_z(sym),rot);
  d2 = rho2 + 1000*theta;
  [d2,th2,rh2] = selectMinbyColumn(d2,theta,rho2);
else
  rho2 = modCentered(pi + rho,rotangle_max_z(sym),rot);
  d2 = rho2 + 1000*(pi-theta);
  [d2,th2,rh2] = selectMinbyColumn(d2,pi-theta,rho2);
end

if check_option(varargin,'antipodal')
  swap = false(numel(v),1);
else
  swap = d1 > d2;
end

[d,theta,rho] = selectMinbyColumn([d1;d2],[th1;th2],[rh1;rh2]);
v = sph2vec(theta,rho);

function d = modCentered(a,b,c)

d = mod(a-c,b)+c;
