function varargout = get(grains, vname)
% get object property or intersection with ebsd 
%
%% Input
%  grains - @grain
%  option - string
%
%% Output
%  grains   - selected grains
%  id       - ids of selection
%
%% Example
%  %return ids and ids-list of neighbours
%  get(grains,'id')
%  get(grains,'neighbour')
%

if nargin > 1
  %assert_property(grains,vname);
  switch vname
    case {'CS','SS'}
      [phase,uphase,id] = get(grains,'phase');
      
      sym = cell(size(id));
      for l=1:length(id)
        sym{l} = get(grains(id(l)).orientation,vname);
      end
      varargout{1} = sym;
    case 'phase'
      phase = zeros(size(grains));
      for k=1:numel(grains)
        phase(k) = grains(k).phase;
      end
      varargout{1} = phase;
      if nargout > 1
        [varargout{2}, varargout{3}] = unique(phase,'first');
      end
    case {'neighbour' 'cells'}
      varargout{1} = {grains.(vname)};
    case fields(grains)
      varargout{1} = [grains.(vname)];
    case fields(grains(1).properties)
      opt = cell(size(grains));
      for k=1:length(opt)
        opt{k} = grains(k).properties.(vname);
      end
      
      kind = grains(1).properties.(vname);
      if (isnumeric(kind) || isa(kind,'quaternion')) && ...
          sum(cellfun('prodofsize',opt)) == length(grains)
        opt = [opt{:}];
      end
      varargout{1} = opt;
    otherwise
      error('Unknown field in class grain')
  end
else
  error('wrong usage')
end
