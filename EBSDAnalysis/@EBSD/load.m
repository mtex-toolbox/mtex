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
interface = strrep(interface,'.','');

options = {};

switch char(interface)
  case {'h5','h5oina','oh5','hdf5','dream3d'}
    ebsd = loadEBSD_universal_hdf5(fname,varargin{:});
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

end
