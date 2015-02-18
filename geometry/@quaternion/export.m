function export(q,fname,varargin)
% export quaternions to a ascii file
%
% Input
%  q - @quaternion
%  fname - filename
%
% Options
%  quaternion - export quaternion values
%  Bunge      - export Bunge Euler angles (default)
%  Matthies   - export Matthies Euler angles (alpha beta gamma)
%  degree     - output in degree (default)
%  radians    - output in radians

if check_option(varargin,'quaternion')

  d = [q.a(:),q.b(:),q.c(:),q.d(:)];
  columnNames = {'a','b','c','d'};
  
else
  
  % add Euler angles
  [d,columnNames] = q.Euler(varargin{:});

end
  
if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree;
end

cprintf(d,'-Lc',columnNames,'-fc',fname,'-q',true);
