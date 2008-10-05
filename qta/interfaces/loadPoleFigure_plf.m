function pf = loadPoleFigure_plf(fname,varargin)
% load dubna cnv file 
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

try
  [fdir,fn,ext] = fileparts(fname);
  mtex_assert(any(strcmpi(ext,{'.plf'})));
  fid = efopen(fname);
catch
  error('file not found or format PLF does not match file %s',fname);
end

try
  ip = 1;
  while ~feof(fid)
    hkl = fgetl(fid);
    h = string2Miller(hkl(1:4));

    d = textscan(fid,'%f','delimiter','\n');
        fgetl(fid); %skip stars  
    d = d{:};
    d(isnan(d)) = [];
    
    r =  S2Grid('Regular','Points',[90 17],'MINTHETA',0,'MAXTHETA',80*degree); 
   
    pf(ip) = PoleFigure(h,r,d,symmetry('cubic'),symmetry('triclinic'));
    ip = 1 + ip;    
  end  
catch
  if ~exist('pf','var')
    error('format PLF does not match file %s',fname);
  end
end

fclose(fid);