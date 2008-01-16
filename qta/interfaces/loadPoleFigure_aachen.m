function pf = loadPoleFigure_aachen(fname,varargin)
% import data fom aachen ptx file
%
%% Syntax
% pf = loadPoleFigure_aachen_exp(fname,<options>)
%
%% Input
%  fname  - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% interfaces_index aachen_interface loadPoleFigure


fid = efopen(fname);

ih = 1;

while ~feof(fid)
  
  try
    % one comment line
    fgetl(fid);
      
    % one line describing hkl and grid of specimen directions
%  003 hxxxx  5.00 5.00 90.00    1    0  (12f6.0)
    l = fgetl(fid);
    h = string2Miller(l(1:6));
    dtheta = str2double(l(11:15));
    dphi   = str2double(l(16:20));
    maxtheta = str2double(l(21:25));
    align = str2double(l(26:30));
  
    if 0.5 > dtheta || 20 < dtheta || 0.5 > dphi || 20 < dphi ||...
        10 > maxtheta || maxtheta > 90
      error('format Aachen does not match file %s',fname);
    end
    
    rho   = (0:dphi:355) * degree;
    theta = (0:dtheta:maxtheta)*degree;
    rho = repmat(rho.',1,length(theta));
    theta = repmat(theta,size(rho,1),1);
    r = S2Grid(sph2vec(theta,rho),'resolution',min(dtheta,dphi)*degree,'hemisphere');
 
    % skip next line
%  1000 .500 -112    0   0.   experimental data
    fgetl(fid);

    d = fscanf(fid,'%e',GridSize(r));
  
    pf(ih) = PoleFigure(h,r,d,symmetry('cubic'),symmetry,varargin{:});
    
    % goto next line
    fgetl(fid);
    ih = ih +1;
    
  catch
    error('format Aachen does not match file %s',fname);
  end
end

fclose(fid);
