function export_ctf(ebsd,fName,varargin)
% export EBSD data to a Channel 5 text file (ctf)
%
% Deprecated, use <exportEBSD_ctf.html exportEBSD_ctf> or
% <EBSD.export.html export> instead - this is a thin wrapper kept so that
% existing scripts keep working.
%
% Syntax
%   export_ctf(ebsd,'myFile.ctf')
%
% Input
%  ebsd  - @EBSD
%  fName - filename
%
% See also
% exportEBSD_ctf EBSD.export

exportEBSD_ctf(ebsd,fName,varargin{:});

end
