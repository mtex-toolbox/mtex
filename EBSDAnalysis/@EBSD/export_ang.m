function export_ang(ebsd,fName,varargin)
% export EBSD data to a TSL/EDAX text file (ang)
%
% Deprecated, use <exportEBSD_ang.html exportEBSD_ang> or
% <EBSD.export.html export> instead - this is a thin wrapper kept so that
% existing scripts keep working.
%
% Syntax
%   export_ang(ebsd,'myFile.ang')
%
% Input
%  ebsd  - @EBSD
%  fName - filename
%
% See also
% exportEBSD_ang EBSD.export

exportEBSD_ang(ebsd,fName,varargin{:});

end
