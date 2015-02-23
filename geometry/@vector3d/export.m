function export(v,fname,varargin)
% export quaternions to a ascii file
%
% Input
%  v - @vector3d
%  fname - filename
%
% Options
%  polar   - export polar coordinates
%  xyz     - export x, y, z coordinates (default)
%  degree  - output in degree (default)
%  radians - output in radians

if check_option(varargin,'polar')

  d = [v.theta(:), v.rho(:)];
  columnNames = {'polar angle','azimuth angle'};

  if ~check_option(varargin,{'radians','radiant','radiand'})
    d = d ./ degree;
  end
  
else
  
  % add Euler angles
  d = [v.x(:),v.y(:),v.z(:)];
  columnNames = {'x','y'};
  
end
  
cprintf(d,'-Lc',columnNames,'-fc',fname,'-q',true);
