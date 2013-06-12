function rho = rotangle_max_z(s,varargin)
% maximum angle rho

switch Laue(s)   
  case '-1'                          % I
    rho = 2*pi;
  case '2/m'                         % C2
    rot = get(s,'rotation');
    if ~isnull(dot(get(rot(2),'axis'),zvector)) || check_option(varargin,'antipodal')
      rho = pi;
    else      
      rho = 2*pi;      
    end    
  case {'mmm','m-3'}               % D2, T
    rho = pi/(1+check_option(varargin,'ALPHA'));
  case '-3'                          % C3
    rho = 2*pi/3;
  case '-3m'                         % D3
    rho = 2*pi/3/(1+check_option(varargin,'antipodal'));
  case {'4/m','4/mmm','m-3m'}  % C4, D4, O
    rho = pi/2;
  case {'6/m','6/mmm'}               % C6, D6
    rho = pi/3;
end
