function [ebsd,interface,options] = loadEBSD(fname,varargin)
% import ebsd data 
%
% Description
% *loadEBSD* is a high level method for importing EBSD data from external
% files. It autodetects the format of the file. As parameters the method
% requires a filename and the crystal and specimen @symmetry. Furthermore,
% you can specify a comment to be associated with the data. In the case of
% generic ascii files each of which consist of a table containing in each
% row the euler angles of a certain orientation see
% <loadEBSD_generic.html loadEBSD_generic> for additional options.
%
% Syntax
%   ebsd = loadEBSD(fname)
%
% Input
%  fname     - filename
%
% Options
%  interface  - specific interface to be used
%
% Output
%  ebsd - @EBSD
%
% See also
% ImportEBSDData EBSD/calcODF ebsd_demo loadEBSD_generic

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

if length(ebsd.unitCell) == 4, 
  %ebsd = ebsd.gridify;
end
