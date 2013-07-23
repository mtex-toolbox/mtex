function theta = rotangle_max_y(s,varargin)
% maximum angle rho

switch Laue(s)   
  case {'-1','-3','4/m','6/m'}
    theta = 2*pi/(1+check_option(varargin,'antipodal'));
  case {'mmm','-3m','4/mmm','m-3m','6/mmm','m-3'}
    theta = pi;
  case '2/m'
    rot = get(s,'rotation');
    if isnull(dot(get(rot(2),'axis'),zvector)) || check_option(varargin,'antipodal')
      theta = pi;      
    else      
      theta = 2*pi;
    end
end
