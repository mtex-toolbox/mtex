function ebsd = loadEBSD_csv(fname,varargin)

ebsd = EBSD;

try
% read file header
fl = file2cell(fname,200);

%number of header lines
nh = find(strmatch('#',fl),1,'last');
hl =   fl(1:nh);

% check that the header fits the format:
%# Column 1-3: phi1, PHI, phi2 (orientation of point in radians)
%# Column 4-5: x, y (coordinates of point in microns)
%# Column 6:   IQ (image quality)
%# Column 7:   CI (confidence index)
%# Column 8:   Fit (degrees)
%# Column 9:   phase (index identifying phase)
%# Column 10:  sem (detector signal value)
try
  
  % find euler angles
  angles = regexpi(hl,'# Column (\d+)-(\d+):\s* phi1, PHI, phi2','tokens');
  angles = [angles{:}];
  angles = str2double(angles{:});
  angles = angles(1):angles(2);
  assert(length(angles)==3);
  
  % find xy
  xy = regexpi(hl,'# Column (\d+)-(\d+):\s* x, y','tokens');
  xy = [xy{:}];
  xy = str2double(xy{:});
  assert(length(xy)==2);
  
  % find all other properties  
  props = regexp(hl,'# Column (\d+):\s* (\w*)','tokens');
  columns = [];
  columnNames = {};
  
  for i = 1:length(props)
    if ~isempty(props{i})
      columns = [columns,str2double(props{i}{:}(1))]; %#ok<AGROW>
      columnNames = [columnNames,{props{i}{:}{2}}]; %#ok<AGROW>
    end
  end
  
catch %#ok<CTCH>
  error('MTEX:wrongInterface','Interface xxx does not fit file format!');
end

if check_option(varargin,'check'), return;end

iphase = columns(strcmpi(columnNames,'phase'));
columns = [angles,xy,columns];
iphase = columns == iphase;

format = repcell('%f',1,max(columns));

% check whether phase is numeric or not
test = textscan(fl{end},[format{:}],1);
if isempty(test{iphase}), format{iphase} = '%s';end

% read data
fid = fopen(fname);
d = textscan(fid,[format{:},'%*[^\n]'],'HeaderLines',nh);
fclose(fid);

% extract phases from names
if isempty(test{iphase})
    
  phases = unique(d{iphase});  
  d{iphase} = cellfun(@(s) find(strcmp(s,phases)),d{iphase});
  for i = 1:numel(phases)
    cs{i} = crystalSymmetry('cubic','mineral',phases{i}); %#ok<AGROW>
  end
  varargin = [{'CS',cs},varargin];
  
end

% generate EBSD variable
ebsd = loadEBSD_generic([d{:}],'bunge','radiant',...
  'ColumnNames',[{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y'} columnNames],...
  'Columns',columns,varargin{:});


catch
  interfaceError(fname)
end
