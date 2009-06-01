function ebsd = loadEBSD_xxx(fname,varargin)

% read file header
hl = file2cell(fname,200);

%number of header lines
nh = find(strmatch('#',hl),1,'last');
hl =   {hl{1:nh}};

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
      columnNames = {columnNames{:},props{i}{:}{2}};
    end
  end
  
catch %#ok<CTCH>
  error('MTEX:wrongInterface','Interface xxx does not fit file format!');
end

if check_option(varargin,'check'), return;end

ebsd = loadEBSD_generic(fname,'bunge','radiant',...
  'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' columnNames{:}},...
  'Columns',[angles,xy,columns],varargin{:},'header',nh);
