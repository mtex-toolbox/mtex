function [ebsd,interface,options] = load(fname,varargin)
% load ebsd data from file
%
% Description
%
% EBSD.load is a high level method for importing EBSD data from files. If
% possible it autodetects the format of the file. Supported formats are
% listed <supportedInterfaces.html here>. Additionally, EBSD data can be
% read from column aligned text file or excel spread sheets. In those cases
% it is necessary to tell MTEX the column positions of the spatial
% coordinates, the phase information as well as Euler angles.
%
% Syntax
%   ebsd = EBSD.load('filename.ang')
%   ebsd = EBSD.load('filename.ctf')
%   ebsd = EBSD.load('filename.osc')
%   ebsd = EBSD.load('filename.hf5')
%
%   csList = {'notIndexed',...
%   CS = {'notIndexed',...
%          crystalSymmetry('m-3m','mineral','Fe'),...
%          crystalSymmetry('m-3m','mineral','Mg')};
%   ebsd = EBSD.load(fname,'cs',cs,'ColumnNames',{'x','y','Euler1','Euler2','Euler3','phase'})
%
% Input
%  fname     - filename
%  cs - @crystalSymmetry or cell array of @crystalSymmetry
%
% Options
%  EulerCorrection   - rotation that is applied to the Euler angles to align Euler and map reference system
%  ColumnNames       - names of the columns to be imported, mandatory are euler 1, euler 2, euler 3
%  Columns           - positions of the columns to be imported
%  radians           - treat input in radiand
%  delimiter         - delimiter between numbers
%  header            - number of header lines
%  Bunge             - [phi1 Phi phi2] Euler angle in Bunge convention (default)
%  passive           -
%  noGrid            - keep the data as a list, do not put it on its grid
%
% Note
% Imported data is put on its grid - i.e. returned as @EBSDsquare or
% @EBSDhex rather than as a plain list - whenever that can be done without
% losing measurements. Pass 'noGrid', or set
%
%   setMTEXpref('gridifyOnImport',false)
%
% to always get a plain list. Data that does not sit on a single lattice is
% never gridded; see EBSD/gridify.
%
% Output
%  ebsd - @EBSD
%
% Example
%
%   fname = fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt');
%   CS = {'notIndexed',...
%          crystalSymmetry('m-3m','mineral','Fe'),...
%          crystalSymmetry('m-3m','mineral','Mg')};
%
%   ebsd = EBSD.load(fname,'CS',CS, 'ColumnNames', ...
%     {'Index' 'Phase' 'x' 'y' 'Euler1' 'Euler2' 'Euler3' 'MAD' 'BC' 'BS'...
%     'Bands' 'Error' 'ReliabilityIndex'}, 'Bunge')
%
% See also
% EBSDImport EBSD/EBSD

% extract file names
fname = getFileNames(fname);

% iterate for multiple files
if numel(fname) > 1
  ebsd = cell(numel(fname),1);
  for k = 1:numel(fname)
    ebsd{k} = EBSD.load(fname{k},varargin{:});
  end
  return
end

fname = char(fname);
[~,~,interface] = fileparts(fname);
interface = get_option(varargin,'interface',interface);
interface = lower(strrep(interface,'.',''));

options = {};

switch char(interface)
  case {'h5','h5oina','oh5','hdf5','dream3d'}
    ebsd = loadEBSD_h5(fname,varargin{:});
  case {'edaxh5'}
    ebsd = loadEBSD_h5(fname,'type','.edaxh5',varargin{:});
  case 'ang'
    ebsd = loadEBSD_ang(fname,varargin{:});
  case 'ctf'
    ebsd = loadEBSD_ctf(fname,varargin{:});
  case {'cpr','crc'}
    ebsd = loadEBSD_crc(fname,varargin{:});
  case {'osc'}
    ebsd = loadEBSD_osc(fname,varargin{:});
  case 'mat'
    obj = load(fname);
    fn = fieldnames(obj);
    for k = 1:length(fn)
      if isa(obj.(fn{k}),'EBSD')
        ebsd = obj.(fn{k});
        return;
      end
    end    
  otherwise
    ebsd = loadEBSD_generic(fname,varargin{:});
end

% put the data on its grid - most scans are a complete raster, and holding
% them as one saves every later plot from rebuilding the lattice
if getMTEXpref('gridifyOnImport',true) && ~check_option(varargin,'noGrid') ...
    && isa(ebsd,'EBSD') && ~isa(ebsd,'EBSDgrid') && ~isa(ebsd,'EBSD3') ...
    && ~isempty(ebsd)

  ebsd = tryGridify(ebsd);

end

end

% =========================================================================
function ebsd = tryGridify(ebsd)
% put ebsd on its grid, but only when no measurement is lost by doing so
%
% gridify writes the measurements into a rectangular raster, which is only
% faithful when they really do sit on one lattice. Three ways that fails,
% all of them properties of the data rather than of the import, so none of
% them may abort a load - each falls back to the plain list and says why:
%
%  - two measurements landing in the same cell. squarify scatters with
%    phaseId(ind) = ..., so the second one silently overwrites the first
%    (eclogite.ctf loses 48 of 613 that way). hexify asserts instead.
%  - calcMesh sizes its raster from max(ij) with no upper bound, so a
%    single stray position can ask for a lattice of tens of thousands of
%    cells per side - big enough to take the machine down.
%  - a degenerate unit cell, which throws in latticeBasis.

nIndexed = nnz(ebsd.isIndexed);

try

  % bound the raster BEFORE building it: calcMesh allocates first and would
  % run out of memory rather than return
  ij = ebsd.lattice.ij;
  nCells = prod(max(ij,[],1) - min(ij,[],1) + 1);

  % a scan may legitimately leave holes, so allow the raster to be a good
  % deal bigger than the measurement count - this is a sanity bound against
  % a stray position, not a density criterion
  if ~isfinite(nCells) || nCells > 10 * max(1,length(ebsd))
    warning('MTEX:load:notOnGrid',...
      ['The measurements span %d lattice cells but there are only %d of ' ...
      'them, so they do not form a grid. Keeping the data as a list - ' ...
      'call gridify explicitly if you want the raster anyway.'],...
      nCells, length(ebsd));
    return
  end

  ebsdGrid = gridify(ebsd);

catch ME

  warning('MTEX:load:notOnGrid',...
    ['The measurements could not be put on a grid (%s). Keeping the data ' ...
    'as a list - call gridify explicitly for the full error.'], ME.message);
  return

end

% gridify keeps one measurement per lattice cell, so fewer indexed pixels
% than we started with means measurements collided and were dropped
if nnz(ebsdGrid.isIndexed) < nIndexed

  warning('MTEX:load:notOnGrid',...
    ['%d of %d indexed measurements share a lattice cell with another ' ...
    'one, so gridding them would drop those measurements. Keeping the ' ...
    'data as a list - call gridify explicitly if you want the raster ' ...
    'anyway.'], nIndexed - nnz(ebsdGrid.isIndexed), nIndexed);
  return

end

ebsd = ebsdGrid;

end
