function export(ebsd,fname,varargin)
% export EBSD data to a file
%
% Description
%
% The file format is taken from the extension of the file name. Formats
% that a vendor software reads are written by the interfaces in
% |mtex/interfaces|, everything else is written as a plain ascii table with
% one line per measurement.
%
% Syntax
%
%   export(ebsd,'myFile.ang')     % TSL / EDAX
%   export(ebsd,'myFile.ctf')     % Oxford / Channel 5
%   export(ebsd,'myFile.h5oina')  % HDF5, written into a copy of the file
%                                 % the data was imported from
%   export(ebsd,'myFile.txt')     % ascii table
%
% Input
%  ebsd - @EBSD
%  fname - filename
%
% Options
%  Bunge   - Bunge convention (default)
%  ABG     - Matthies convention (alpha beta gamma)
%  degree  - output in degree (default)
%  radians - output in radians
%
% See also
% exportEBSD_ang exportEBSD_ctf exportEBSD_h5

[~,~,ext] = fileparts(fname);
switch lower(ext)
  case {'.crc','.cpr'}
    export_crc(ebsd,fname,varargin{:});
    return
  case {'.h5','.hdf5','.h5oina','.oh5','.edaxh5','.dream3d','.h5ebsd'}
    exportEBSD_h5(ebsd,fname,varargin{:});
    return
  case '.ctf'
    exportEBSD_ctf(ebsd,fname,varargin{:});
    return
  case '.ang'
    exportEBSD_ang(ebsd,fname,varargin{:});
    return
end

fn = fields(ebsd.prop);

% allocate memory
d = zeros(length(ebsd),4+numel(fn));

% add Euler angles
[d(:,1:3),EulerNames] = ebsd.rotations.Euler(varargin{:});
if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree;
end

% add phase
d(:,4) = reshape(ebsd.phase,1,[]);

% update fieldnames
fn = [EulerNames.';'phase';fn];

% add properties
for j = 5:numel(fn)
  if isnumeric(ebsd.prop.(fn{j}))
    d(:,j) = vertcat(reshape(ebsd.prop.(fn{j}),1,[]));
  elseif isa(ebsd.prop.(fn{j}),'quaternion')
    d(:,j) = angle(reshape(ebsd.prop.(fn{j}),1,[])) / degree;
  end
end

cprintf(d,'-Lc',fn,'-fc',fname,'-q',true);
