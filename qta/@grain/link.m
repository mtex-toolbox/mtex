function varargout = link(varargin)
% get intersection with ebsd 
%
%% Syntax
%  [grains ebsd ids] = link(grains,ebsd) 
%  [ebsd grains ids] = link(ebsd,grains) 
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD
%
%% Output
%  grains   - selected grains
%  ebsd     - selected ebsd data
%  ids      - the ids of ebsd data
%
%% Example
%  %return the grains of a given ebsd data 
%  link(grains,ebsd)
%
%  %return the ebsd data of a given grains
%  link(ebsd,grains)
%

grain_pos = find_type(varargin,'grain');
ebsd_pos  = find_type(varargin,'EBSD');
if isempty(ebsd_pos), error('MTEX:linkGrainEbsd','Missing EBSD Object'); end
 
grains = varargin{grain_pos};
ebsd = varargin{ebsd_pos};
[me mg ids] = assert_checksum(grains,ebsd);
varargout{ebsd_pos} = copy(ebsd,me);
varargout{grain_pos} = grains(mg);     

if nargout > 2, varargout{3} = ids; end
