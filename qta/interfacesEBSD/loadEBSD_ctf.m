function ebsd = loadEBSD_ctf(fname,varargin)
% load EBSD data from CTF files
%
%% Syntax
%  ebsd   = loadEBSD_txt(fname)
%
%% See also
% interfacesEBSD_index loadEBSD ebsd_demo


try
  [fdir,fn,ext] = fileparts(fname);
  mtex_assert(any(strcmpi(ext,{'.ctf'})));
catch
  error('file not found or format ctx does not match file %s',fname);
end

try
	group = {'-1','2/m','mmm','4/m','4/mmm','-3','-3m','6/m','6/mmm','m-3','m-3m'}; 
  
  fid = fopen(fname);

  textscan(fid,'%s',6,'delimiter','\t');
  mode=textscan(fid,'%s',1);
          
  if strcmp(mode{1},'Grid'),n=7;
  elseif strcmp(mode{1},'Interactive'), n=4;  end
  for i=1:n+2,fgetl(fid);end
  
  % Crystallogaphic Parameters of all phases
  textscan(fid,'%s',1,'delimiter','\t');
  
  phases = textscan(fid,'%u',1,'delimiter','\n'); 
  for i=1:phases{1}
    sym  = textscan(fid,'%f',6,'delimiter',';\t');
    info = textscan(fid,'%s%u%u%s%s%s',1,'delimiter','\t\n');    
    cs(i) = symmetry(group{ info{2} }, sym{1}(1:3)', sym{1}(4:6)'*degree);
  end
  
  fclose(fid);
  
  ebsd = loadEBSD(fname,'interface','generic', 'Bunge', 'layout', [6 7 8], 'Phase', 1, 'xy', [2 3], 'ColumnNames', { 'Bands' 'Error' 'MAD' 'BC' 'BS' } , 'ColumnIndex', [4 5 9 10 11], 'ascii');

  for i = 1:numel(ebsd)
    ph = get(ebsd(i),'phase');
    if ph > 0
      ebsd = set(ebsd,i,'CS',cs(ph));
    end
  end
catch
  error('format ctx does not match file %s',fname);
end
