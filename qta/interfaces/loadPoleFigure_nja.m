function pf =loadPoleFigure_nja(fname,varargin)

try
  [fdir,fn,ext] = fileparts(fname);
  mtex_assert(any(strcmpi(ext,{'.nja'})));
catch
  error('file not found or format nja does not match file %s',fname);
end

comment = '';
fid = efopen(fname);
try
%% read header
	comment = textscan(fid,'%s',45,'delimiter','&','whitespace','');
catch
	error('format nja does not match file %s',fname);
end
fclose(fid);

try
  % read data
	d = dlmread(fname,'',21,0);
	th = d(:,1)*degree;
	rh = d(:,2)*degree;
	bg  = d(:,4);
	d  = d(:,3);
     
	h = string2Miller(regexprep([comment{1}{19:21}], '[A-Z=\s]', '', 'ignorecase'));
	r = S2Grid(sph2vec(th,rh),'reduced'); 
  
	pf = PoleFigure(h,r,d,symmetry('cubic'),symmetry,'BACKGROUND',bg,varargin{:});
catch
  error('format nja does not match file %s',fname);
end