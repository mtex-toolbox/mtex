function export(v,fname,varargin)
% export quaternions to a ascii file
%
% Input
%  v - @vector3d
%  fname - filename
%  S - struct containing additional properties to be exported
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
  
else % Euclidean coordinates x, y, z
  
  d = [v.x(:),v.y(:),v.z(:)];
  columnNames = {'x','y','z'};
  
end
  
% export additional properties
S = getClass(varargin,'struct');
if ~isempty(S)
  for fn = fieldnames(S).'
    columnNames = [columnNames,fn]; %#ok<AGROW>
    dd = S.(char(fn));
    d = [d,double(dd(:))]; %#ok<AGROW>
  end
end

% write to file
cprintf(d,'-Lc',columnNames,'-fc',fname,'-q',true);
