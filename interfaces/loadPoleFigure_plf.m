function pf = loadPoleFigure_plf(fname,varargin)
% load plf file
%
% Syntax
%   pf = loadPoleFigure_plf(fname)
%
% Input
%  fname - file name
%
% Output
%  pf    - @PoleFigure
%

assertExtension(fname,'.plf');

fid = fopen(fname,'r');

r =  regularS2Grid('Points',[90 17],'MINTHETA',0,'MAXTHETA',80*degree);

try
  ip = 1;
  while ~feof(fid)
    hkl = fgetl(fid);
    h{ip} = string2Miller(hkl(1:4));
    
    tmp = textscan(fid,'%f','delimiter','\n');
    fgetl(fid); %skip stars
    tmp = tmp{:};
    tmp(isnan(tmp)) = [];
    d{ip} = tmp;           
    ip = 1 + ip;
  end
  
  pf = PoleFigure(h,r,d,varargin{:});
catch
  if ~exist('pf','var')
    interfaceError(fname,fid);
  end
end

fclose(fid);
