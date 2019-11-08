function cs = load(fname,varargin)
% import crystal symmetry from phl or cif files
%
% if cif file not found and input name is a valid COD entry, this function
% tries to download the file from
% <http://www.crystallography.net/cif/ http://www.crystallography.net/cif/>
%
% Syntax
%   cs = crystalSymmetry.load('5000035.cif') % load from cif file
%   cs = crystalSymmetry.load('copper.phl') % load from phl file
%   cs = crystalSymmetry.load(5000035) % lookup online
%
% See also
% crystalSymmetry/crystalSymmetry
%

[~, ~, ext] = fileparts(char(fname));

if strcmpi(ext,'.phl')
  cs = loadPHL(fname,varargin{:});
else
  cs = loadCIF(fname,varargin{:});
end
