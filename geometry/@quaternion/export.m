function export(q,fname,varargin)
% export quaternions to a ascii file
%
% Syntax
%
%   fname = 'fileName.txt'
%   export(ori,fname)
%   export(ori,fname,'radians','Bunge')
%
%   fit ellipses to grains and store halfaxes and orientation in a struct
%   [S.angle,S.a,S.b] = fitEllipse(grains);
%
%   % store area
%   S.area = grains.area;
%   
%   % export orientation and custom data
%   export(grains.meanOrientation,fname,S)
%
% Input
%  q - @quaternion
%  fname - filename
%  S - struct
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

% store additional information
S = getClass(varargin,'struct');
if ~isempty(S)
  for fn = fieldnames(S).'
    columnNames = [columnNames,fn];
    dd = S.(char(fn));
    d = [d,double(dd(:))]; %#ok<AGROW>
  end
end

cprintf(d,'-Lc',columnNames,'-fc',fname,'-q',true);
