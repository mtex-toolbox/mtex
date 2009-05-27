function theta = rotangle_max_y(s,varargin)
% maximum angle rho

switch Laue(s)   
  case {'-1', '2/m','-3','4/m','6/m'}
    theta = 2*pi/(1+check_option(varargin,'axial'));
  case {'mmm','-3m','4/mmm','m-3m','6/mmm','m-3'}
    theta = pi;
end
