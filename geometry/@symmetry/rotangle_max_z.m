function rho = rotangle_max_z(s,varargin)
% maximum angle rho

switch Laue(s)   
  case '-1'                          % I
    rho = 2*pi;
  case '2/m'                         % C2
    rho = pi;
  case 'mmm'                         % D2
    rho = pi/(1+check_option(varargin,'ALPHA'));
  case '-3'                          % C3
    rho = 2*pi/3;
  case '-3m'                         % D3
    rho = 2*pi/3/(1+check_option(varargin,'REDUCED'));
  case {'4/m','4/mmm','m-3','m-3m'}  % C4, D4, O, T
    rho = pi/2;
  case {'6/m','6/mmm'}               % C6, D6
    rho = pi/3;
end
