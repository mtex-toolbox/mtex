function pf = loadPoleFigure_plf(fname,varargin)
% load plf file
%
%% Syntax
% pf = loadPoleFigure_plf(fname,<options>)
%
%% Input
%  fname - file name
%
%% Output
%  pf    - @PoleFigure
%

assertExtension(fname,'.plf');

fid = fopen(fname,'r');

try
  ip = 1;
  while ~feof(fid)
    hkl = fgetl(fid);
    h = string2Miller(hkl(1:4));
    
    d = textscan(fid,'%f','delimiter','\n');
    fgetl(fid); %skip stars
    d = d{:};
    d(isnan(d)) = [];
    
    r =  regularS2Grid('Points',[90 17],'MINTHETA',0,'MAXTHETA',80*degree);
    
    pf(ip) = PoleFigure(h,r,d,varargin{:});
    ip = 1 + ip;
  end
catch
  if ~exist('pf','var')
    interfaceError(fname,fid);
  end
end

fclose(fid);
