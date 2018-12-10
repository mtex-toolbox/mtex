function ebsd = loadEBSD_Oxfordcsv(fname,varargin)

activePassive = {'passive','active'};

ebsd = EBSD;

try

  % read header
  fid = efopen(fname);
  s = fgetl(fid);
  assert(strcmpi(s,'Phase,ID'));
  
  % read phase names
  cs = {};
  s = fgetl(fid);
  hl = 0;
  while ~isempty(s)    
    hl = hl + 1;
    phase = textscan(s,'%s%d','WhiteSpace',',');
    if phase{2}
      cs{hl} = crystalSymmetry('cubic','mineral',phase{1}{1});     %#ok<AGROW>
    else
      cs{hl} = phase{1}{1};     %#ok<AGROW>
    end
    s = fgetl(fid);
  end
    
  while ~strncmp(s,'Point',5)
    s = fgetl(fid);
    
    % extract active passive flag
    flag = sscanf(s,'Bunge Euler Convention, %f');
    if ~isempty(flag), activePassive = activePassive{1+flag}; end
    hl = hl + 1;
  end
  colNames = s;
  fclose(fid);

  % passive is default
  if iscell(activePassive), activePassive = activePassive{1}; end
  
  if check_option(varargin,'check'); return;end

  % extract column names
  colNames = textscan(colNames,'%s','delimiter',',');
  colNames = strrep(colNames{1},'Crystal ID','phase');
  
  % read data via generic interface
  ebsd = loadEBSD_generic(fname,'CS',cs,'header',hl+3,'delimiter',',',...
    'ColumnNames',colNames,'bunge',activePassive,varargin{:},'keepNaN');

catch
  interfaceError(fname)
end
