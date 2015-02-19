function ebsd = loadEBSD_sor(fname,varargin)
% load LaboTex *.sor file
%
% Input
% fname - file name
%
% Output
% ebsd    - @EBSD
%
% See also
% ImportEBSDData

% ensure right extension
try
  [fdir,fn,ext] = fileparts(fname); %#ok<ASGLU>
  assert(any(strcmpi(ext,{'.sor'})));
catch %#ok<CTCH>
  interfaceError(fname);
end

spacegroup =  {'C1','C2','D2','C4','D4','T','O','C3','D3','C6','D6'};


try
  fid = efopen(fname);
  
  % read header
  
  % skip the first 3 lines
  
  textscan(fid,'%s',3,'delimiter','\n','whitespace','');
  
  % read parameter
  d = textscan(fid,'%d %f %f %f %f %f %f %f %d %d %d\n',1);
  
  % define symmetry
  cs = crystalSymmetry(spacegroup{d{1}},[d{2:4}],[d{5:7}]*degree);
  
  if d{9}==0
    options = {'ColumnNames',{'Euler1','Euler2','Euler3'}};
  else
    options = {'ColumnNames',{'Euler1','Euler2','Euler3','Weight'}};
  end
  if d{10}==0, options = [options,{'degree'}];end
  if d{11}==0,
    options = [options,{'Bunge'}];
  else
    options = [options,{'Roe'}];
  end
  
  fclose(fid);
  cs = get_option(varargin,'CS',cs);
  ebsd = loadEBSD_generic(fname,'cs',cs,options{:});
  
catch
  interfaceError(fname);
  
  %   error('format LaboTeX .sor does not match file %s',fname);
end
