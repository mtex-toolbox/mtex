function pf = loadPoleFigure_juelich(fname,varargin)
% load juelich data format
%
% Input
%  fname - file name
%
% Output
%  pf    - vector of @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

% check second commentar line
% alpha      beta intensity
fid = efopen(fname);
try
  fgetl(fid);
  l = fgetl(fid);
  assert(~isempty(regexp(l,'alpha\s*beta\s*intensity','ONCE')),...
    'MTEX:InterfaceJuelichReadingError');
  fclose(fid);
  
  % call txt interface with the right parameters
  pf = loadPoleFigure_generic(fname,'HEADER',2,'ascii',...
    'ColumnNames', {'Polar Angle' 'Azimuth Angle' 'Intensity'}, 'Columns', [1 2 3],...
    'degree',varargin{:});
catch %#ok<CTCH>
  interfaceError(fname,fid);
end
