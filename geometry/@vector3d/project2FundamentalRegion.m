function [v,swap] = project2FundamentalRegion(v,sym,varargin)
% projects orientations to a fundamental region
%
%% Input
%  v  -  @vector3d
%  cs - @symmetry
%
%% Options
%  CENTER - reference orientation
%
%% Output
%  v  - @vector3d
%  dist - distance

%q = quaternion_special(sym);
q = quaternion(sym);

sv = q*v;
[theta,rho] = vec2sph(sv);
rho = mod(rho,rotangle_max_z(sym));

d1 = rho + 1000*theta;
[d1,th1,rh1] = selectMinbyColumn(d1,theta,rho);

d2 = mod(pi+rho,rotangle_max_z(sym)) + 1000*(pi-theta);
[d2,th2,rh2] = selectMinbyColumn(d2,pi-theta,mod(pi+rho,rotangle_max_z(sym)));

if check_option(varargin,'reduced')
  swap = false(numel(v),1);
else
  swap = d1 > d2;
end

[d,theta,rho] = selectMinbyRow([d1,d2],[th1,th2],[rh1,rh2]);
v = sph2vec(theta,rho);
