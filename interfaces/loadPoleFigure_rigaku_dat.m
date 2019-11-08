function pf = loadPoleFigure_rigaku_dat(fname,varargin)
% load *.dat files of rigaku devices
%
% Syntax
%   pf = loadPoleFigure_rigaku_dat(fname)
%
% Input
%  fname  - filename
%
% Output
%  pf - @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

try
  % read header
  hl = file2cell(fname,1);
  
  % check header is x y z data
  assert(strcmp(sscanf(hl{1},'%s %s %s %s'),'XYZdata'));
  
  % read the data
  data = txt2mat(fname,'InfoLevel',0);
  
  x = data(:,1);
  y = data(:,2);
  d = data(:,4);
  
  % assert x,y are within the right range
  assert(all(x>=-90) && all(x<=90)&& all(y>=-90) && all(y<=90));
  
  % compute spherical coordinates
  rho = atan2(y,x);
  theta = sqrt(x.^2 + y.^2)*degree;
  
  % setup specimen directions
  r = vector3d.byPolar(theta,rho,'antipodal');
  
  % guess crystal direction
  h = string2Miller(fname);
  
  pf = PoleFigure(Miller(1,0,0),r,d,varargin{:});
  
catch
  
  if ~exist('pf','var')
    interfaceError(fname);    
  end
  
end

