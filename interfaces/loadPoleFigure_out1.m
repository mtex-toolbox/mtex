function pf = loadPoleFigure_out1(fname,varargin)
% import polfigure-data form Graz
%
% Syntax
%   pf = loadPoleFigure_out1(fname)
%
% Input
%  fname  - filename
%
% Output
%  pf - vector of @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

try
  assert(strcmp(fname(end-2:end),'out'));
  
  data = txt2mat(fname,'NumHeaderLines',15,'NumColumns',2,...
    'InfoLevel',0,'ReadMode','block','BadLineString',{'!@!'});
  
  r = regularS2Grid('points',[72 18],'maxtheta',85*degree);
  
  gz = length(r);
  numpf = length(data)/gz;
  
  cs = crystalSymmetry;
  h = { Miller(1,0,0,cs), Miller(1,1,0,cs),  Miller(1,0,2,cs),  Miller(2,0,0,cs),...
    Miller(2,0,1,cs), Miller(1,1,2,cs),  Miller(2,1,1,cs),  Miller(1,1,3,cs)};
  if numpf > length(h), h(length(h)+1:numpf) = Miller(1,0,0); end
  
  for k=0:numpf-1, d{k+1} = data((k*gz)+1:(k+1)*gz,2); end
  
  pf = PoleFigure(h,r,d,varargin{:});
  
  pf(pf.intensities < 0) = [];
  
catch
  interfaceError(fname);
end
