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
  assert_property(grains,vname);
  switch vname
    case {'neighbour' 'cells'}
      varargout{1} = {grains.(vname)};
    case fields(grains)
      varargout{1} = [grains.(vname)];
    case fields(grains(1).properties)
      if strcmpi(vname,'phase')
        opt = zeros(size(grains));
        for k=1:length(opt), 
          opt(k) = grains(k).properties.(vname);
        end
      else
        opt = cell(size(grains));
        for k=1:length(opt)
          opt{k} = grains(k).properties.(vname);
        end
        
        kind = grains(1).properties.(vname);
        if (isnumeric(kind) || isa(kind,'quaternion')) && ...
            sum(cellfun('prodofsize',opt)) == length(grains)
          opt = [opt{:}];
        end
      end
      varargout{1} = opt;
    otherwise
      error('Unknown field in class grain')
  end
else
  error('wrong usage')
end
