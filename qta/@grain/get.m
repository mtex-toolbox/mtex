function varargout = get(varargin)
% get object property or intersection with ebsd 
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD
%  option - string
%
%% Output
%  grains   - selected grains
%  ebsd     - selected ebsd data
%  id       - ids of selection
%
%% Example
%  %return the grains of a given ebsd data 
%  get(grains,ebsd)
%
%  %return the ebsd data of a given grains
%  get(ebsd,grains)
%
%  %return ids and ids-list of neighbours
%  get(grains,'id')
%  get(grains,'neighbour')
%

if nargin > 1
  type = cellfun(@(x) class(x),varargin,'uniformoutput',false);
  grain_pos = find(strcmpi(type,'grain'));
  ebsd_pos = find(strcmpi(type,'EBSD'));
  opt_pos = find(strcmpi(type,'char'));

  grains = varargin{grain_pos};    
  if ~isempty(ebsd_pos)
    ebsd = varargin{ebsd_pos};
    [me mg ids] = assert_checksum(grains,ebsd);
    varargout{ebsd_pos} = copy(ebsd,me);
    varargout{grain_pos} = grains(mg);     
    if nargout > 2, varargout{3} = ids; end
  elseif ~isempty(opt_pos)
    optfield = varargin{opt_pos};
    
    switch optfield
      case {'neighbour' 'cells'}
        varargout{1} = {grains.(optfield)};
      case fields(grains)
        varargout{1} = [grains.(optfield)]; 
      otherwise
         error('Unknown field in class grain')
    end
  else 
    error('wrong usage')
  end  
end
