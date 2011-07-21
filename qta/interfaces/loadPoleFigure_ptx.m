function pf = loadPoleFigure_ptx(fname,varargin)
% import polefigure from ptx file 
%
%% Input
%  fname - file name
%
%% Output
%  pf    - @PoleFigure
%
%% See also
% ImportPoleFigureData loadPoleFigure


fid = efopen(fname);

try
  % skip first 2 lines
  textscan(fid,'%s',2,'delimiter','\n','whitespace','');


  % 3. line
  % *Corrected, rescaled data * Phi range    0.00 -  360.00 Step    5.00
  % *Reflexion ranges * Phi range    0.00 -  360.00 Step    5.00
  tline = fgetl(fid);
  tline = tline(strfind(tline,'* Phi range'):end);
  rho = textscan(tline,' * Phi range %n - %n Step %n','tokens');
  rho = rho{1}:rho{3}:(rho{2}-rho{3});
  
  % 4. line
  % *Pole figure: 111
  tline = fgetl(fid);
  tline = tline((strfind(tline,'*Pole figure:')+13):end);
  h = string2Miller(tline);
  
  % data block
  
  theta = [];
  d = [];
  
  while ~feof(fid)
  
    % *Khi =   0.00
    th = textscan(fid,'*Khi = %n');
    theta = [theta,th{1}];
    dd = textscan(fid,'%n',numel(rho));
    d = [d,dd{1}];
    
    % goto next line
    fgetl(fid);     
  end
  
  fclose(fid);
    
  r = S2Grid('theta',theta*degree,'rho',rho*degree,'antipodal');
  
  pf = PoleFigure(h,r,d,symmetry('cubic'),symmetry,varargin{:});
catch
    error('format ptx does not match file %s',fname);
end

