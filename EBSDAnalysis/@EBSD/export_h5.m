function export_h5(ebsd,fname,varargin)
% export EBSD data to an HDF5 file
%
% Deprecated, use <exportEBSD_h5.html exportEBSD_h5> or
% <EBSD.export.html export> instead - this is a thin wrapper kept so that
% existing scripts keep working.
%
% Syntax
%   export_h5(ebsd,'myFile.h5')
%
% Input
%  ebsd  - @EBSD
%  fname - filename
%
% See also
% exportEBSD_h5 EBSD.export

exportEBSD_h5(ebsd,fname,varargin{:});

end
