function pf = loadPoleFigure_ana(fname,varargin)
% import data fom ana file
%
% Syntax
%   pf = loadPoleFigure_ana(fname)
%
% Input
%  fname  - filename
%
% Output
%  pf - vector of @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure


fid = efopen(fname);

try
  
  % first line comment
  comment = fgetl(fid);
  comment = strtrim(comment);
  
  % get parameters
  d = textscan(fid,'%f',20);
  d = d{1};
  
  % number of measurements
  N = d(1);
  
  % check parameters
  assert(d(7) >= 0 && d(9)>0 && d(8)>d(7) && d(8)*degree<=pi+0.001);
  assert(d(10) >= 0 && d(12)>0 && d(11)>d(7) && d(11)*degree<=2*pi+0.001);
  
  % construct grid of specimen directions
  theta = (d(6)+(d(7):d(9):d(8)))*degree;
  rho = (d(10):d(12):(d(11)-d(12)))*degree;
  
  % check grid
  assert(numel(theta) < 1000 && numel(rho)<1000);
  
  r = regularS2Grid('theta',theta,'rho',rho,'antipodal');
  h = string2Miller(fname);
  
  
  assert(N == length(r) && N > 10);
  d = textscan(fid,'%f',N);
  d = d{1};
  assert(N == numel(d));
  
  pf = PoleFigure(h,r,d,'comment',comment,varargin{:});
  
catch %#ok<CTCH>
  interfaceError(fname,fid);
end

fclose(fid);
