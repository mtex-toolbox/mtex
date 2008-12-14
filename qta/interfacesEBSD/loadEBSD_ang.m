function ebsd = loadEBSD_ang(fname,varargin)
% load EBSD data from ANG files
%
%% Syntax
%  ebsd   = loadEBSD_ang(fname)
%
%% See also
% interfacesEBSD_index loadEBSD ebsd_demo


try
  [fdir,fn,ext] = fileparts(fname);
  mtex_assert(any(strcmpi(ext,{'.ang'})));
catch
  error('file not found or format ctx does not match file %s',fname);
end

try
  groupalias ={'1','20','2','22','4','42','3','32','6','62','23','43'};
  group = {'-1','2/m','2/m','mmm','4/m','4/mmm','-3','-3m','6/m','6/mmm','m-3','m-3m'}; 
  
  fid = fopen(fname); 
  for i=1:6, fgetl(fid);end
	
  k=1;
	while ~any(cell2mat(...
      cellfun(@(x) strcmp(x,'GRID:'),textscan(fid,'%s',2,'delimiter',' '),'uniformoutput',false)))
      
    for i=1:4,fgetl(fid); end

    g=textscan(fid,'%s',3);
    textscan(fid,'%24s',1,'delimiter','\t'); % Avoid problem of blank spaces   
    sym=textscan(fid,'%f',6);            
    
    cs(k) = symmetry(group{strmatch(g{1}{3},groupalias)},sym{1}(1:3), sym{1}(4:6)*degree);
   
    textscan(fid,'%s',2,'delimiter',' ');% delimiter blank space
        
    fams=textscan(fid,'%u',1); % skip 3 families
    for i=1:fams{1}+3, fgetl(fid);  end
    k=k+1;
  end
  fclose(fid);

  try
    ebsd = loadEBSD(fname,'interface','generic', 'Bunge', 'layout', [1 2 3], 'Phase', 8, 'xy', [4 5], 'ColumnNames', { 'IQ' 'CI' 'Signal' 'Fit' } , 'ColumnIndex', [6 7 9 10], 'ascii');
  catch
    ebsd = loadEBSD(fname,'interface','generic', 'Bunge', 'layout', [1 2 3], 'Phase', 8, 'xy', [4 5], 'ColumnNames', { 'IQ' 'CI' 'Signal' } , 'ColumnIndex', [6 7 9], 'ascii');
  end
  
  for i = 1:numel(ebsd)
    ph = get(ebsd(i),'phase');
    if ph > 0
      ebsd = set(ebsd,i,'CS',cs(ph));
    end
  end
catch
  error('format ctx does not match file %s',fname);
end
