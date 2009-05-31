function ebsd = loadEBSD_xxx(fname,varargin)

% read file header
hl = file2cell(fname,200);

%number of header lines
nh = find(strmatch('#',hl),1,'last');

% check that the header fits the format:
%# Column 1-3: phi1, PHI, phi2 (orientation of point in radians)
%# Column 4-5: x, y (coordinates of point in microns)
%# Column 6:   IQ (image quality)
%# Column 7:   CI (confidence index)
%# Column 8:   Fit (degrees)
%# Column 9:   phase (index identifying phase)
%# Column 10:  sem (detector signal value)
try
  assert(nh>6);
  assert(all((1:(nh-2))' == strmatch('# Column',strvcat(hl{3:nh}))));
catch %#ok<CTCH>
  error('MTEX:wrongInterface','Interface xxx does not fit file format!');
end

if check_option(varargin,'check'), return;end

ebsd = loadEBSD_generic(fname,'bunge','radiant',...
  'ColumnNames',{'Euler 1' 'Euler 2' 'Euler 3' 'X' 'Y' 'IQ' 'CI' 'Phase' 'SEM_signal' 'Fit'},...
  'Columns',1:10,varargin{:},'header',nh);
