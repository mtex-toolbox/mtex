function pf =loadPoleFigure_nja(fname,varargin)


assertExtension(fname,'.nja');

comment = '';
fid = efopen(fname);
try
  % read header
  comment = textscan(fid,'%s',45,'delimiter','&','whitespace','');
  fclose(fid);
catch
  interfaceError(fname,fid);
end


try
  % read data
  d = dlmread(fname,'',21,0);
  th = d(:,1)*degree;
  rh = d(:,2)*degree;
  bg  = d(:,4);
  d  = d(:,3);
  
  h = string2Miller(regexprep([comment{1}{19:21}], '[A-Z=\s]', '', 'ignorecase'));
  r = vector3d.byPolar(th,rh,'antipodal');
  
  pf = PoleFigure(h,r,d,'BACKGROUND',bg,varargin{:});
catch
  interfaceError(fname);
end
