function pf = loadPoleFigure_rigaku(fname,varargin)
% import data fom Rigaku SamrtLab txt file
%
% Syntax
%   pf = loadPoleFigure_rigaku(fname)
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
  hl = file2cell(fname,14);

  % check header starts with %
  assert(all(strmatch('#',hl).' == 1:14));

  % read out some stuff from the header
    
  % read the data
  data = txt2mat(fname,'InfoLevel',0);

  % define specimen directions
  theta = (90 - data(:,1))*degree;
  rho = data(:,2) * degree;
  r = vector3d.byPolar(theta,rho);
  
  % define crystal directions
  h = string2Miller(fname);
  
  % define intensities
  d = data(:,3);
  
  % set uo the pole figure
  pf = PoleFigure(h,r,d,varargin{:});
  
catch
  if ~exist('pf','var')
    interfaceError(fname);
  end
end

