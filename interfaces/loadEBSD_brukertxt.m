function ebsd = loadEBSD_brukertxt(fname,varargin)
% read Bruker *.txt file
%
% Syntax
%   ebsd = loadEBSD_brukertxt(fname)
%


ebsd = EBSD;

try
  
  [cs,nh,columns] = localParseHeader(fname);
  
  ebsd = loadEBSD_generic(fname,'cs',cs,'bunge','degree',...
    'ColumnNames',columns,varargin{:},'header',nh);
  
catch
  interfaceError(fname);
end


function [CS,nh,columns] = localParseHeader(fname)


fid = fopen(fname);
% fetch 10000 chars;
header = fread(fid,10000);
fclose(fid);

phases = struct;
nphase = 0;

lineBreaks = [0; find(header == 10)];
for k=1:numel(lineBreaks)-1
  line = header(lineBreaks(k)+1:lineBreaks(k+1));
  
  if line(1) == 35 %(char(line(1)) == '#')
    lineChars = char(line(2:end))';
    
    sep = find(lineChars == 58);
    
    if numel(sep) > 0
      keyword = lineChars(1:sep(1)-1);
      
      if strncmpi(keyword,'Phase',5)
        
        nphase = nphase + 1;
        phases(nphase).phaseId = nphase;
        
      elseif strncmpi(keyword,' ',1)
        
        keyword = strtrim(keyword);
        param   = strtrim(lineChars(sep(1)+1:end));
        
        phases(nphase).(keyword) = param;
        
      end
      
    else
      columns = regexpsplit(lineChars,'\t');
      columns = cellfun(@strtrim,columns,'UniformOutput',false);
    end
  else
    nh = k - 1;
    break
  end
  
end


requiredFields = {'phaseId';'Name';'Spacegroup';'A';'B';'C';'Alpha';'Beta';'Gamma'};

CS = cell(numel(phases)+1,1);
CS{1} = 'notIndexed';

if all(strcmp(fieldnames(phases),requiredFields))
  
  for k=1:numel(phases)
    
    ax = [eval(phases(k).A) ...
      eval(phases(k).B) ...
      eval(phases(k).C)];
    om = [eval(phases(k).Alpha) ...
      eval(phases(k).Beta) ...
      eval(phases(k).Gamma)]*degree;
    
    SpaceGroup = regexprep(phases(k).Spacegroup,'#ovl|#sub|\(|\)|\*','');
    CS{k+1}= crystalSymmetry(SpaceGroup,ax,om,'mineral',phases(k).Name);
    
  end
  
end
