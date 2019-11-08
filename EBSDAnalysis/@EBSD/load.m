function [ebsd,interface,options] = load(fname,varargin)
% load ebsd data from file
%
% Description
%
% EBSD.load is a high level method for importing EBSD data from files. If
% possible it autodetects the format of the file. Supported formats are
% listed <supportedInterfaces.html here>. Additionally, EBSD data can be
% read from column aligned text file or excel spread sheets. In those cases
% it is neccesary to tell MTEX the column positions of the spatial
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
%  ColumnNames       - names of the colums to be imported, mandatory are euler 1, euler 2, euler 3
%  Columns           - postions of the columns to be imported
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
%   SS = specimenSymmetry('triclinic');
%   ebsd = EBSD.load(fname,'CS',CS,'SS',SS, 'ColumnNames', ...
%     {'Index' 'Phase' 'x' 'y' 'Euler1' 'Euler2' 'Euler3' 'MAD' 'BC' 'BS'...
%     'Bands' 'Error' 'ReliabilityIndex'}, 'Bunge')
%
% See also
% EBSDImport EBSD/EBSD


% extract file names
fname = getFileNames(fname);

if nargin > 1 && (isa(varargin{1},'crystalSymmetry') || ...(
    iscell(varargin{1}))
  varargin = [{'CS'},varargin];
end

% determine interface 
if check_option(varargin,'interface')
  interface = get_option(varargin,'interface');
  options = delete_option(varargin,'interface',1);
elseif check_option(varargin,'columnNames')
  interface = 'generic';
  options = varargin;
else
  [interface,options] = check_interfaces(fname{1},'EBSD',varargin{:});
  if isempty(interface), return; end
end

% show waitbar for 3d
is3d = check_option(varargin,'3d');
if is3d
  hw = waitbar(0,'Loading data files.');
  Z = get_option(varargin,'3d',1:numel(fname),'double');
end
  
for k = 1:numel(fname)

  % load the data
  ebsd{k} = feval(['loadEBSD_',char(interface)],...
    fname{k},options{:},'InfoLevel',~is3d,varargin{:});   %#ok<AGROW>
  
  % assign Z - value
  if is3d
    [~,fn,ext] = fileparts(fname{k});
    waitbar(k/numel(fname),hw,['Loaded data file ',[fn ext]]);
    ebsd{k}.z = repmat(Z(k),length(ebsd{k}),1); %#ok<AGROW>
  end  
end

% combine multiple inputs
ebsd = [ebsd{:}];

% compute unit cell for 3d data
if check_option(varargin,'3d')    
  ebsd.unitCell = calcUnitCell([ebsd.x(:),ebsd.y(:),ebsd.z(:)],varargin{:});
  close(hw)
end

% should we automatically gridify?
%ebsd = ebsd.gridify;
