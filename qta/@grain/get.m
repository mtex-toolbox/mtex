function varargout = get(grains, vname, varargin)
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
      varargout{1} = [grains.phase];
      if nargout > 1
        [varargout{2}, varargout{3}] = unique(varargout{1},'first');
      end
    case {'neighbour' 'cells'}
      varargout{1} = {grains.(vname)};
    case {'orientations','orientation'}
      
      if check_option(varargin,'phase')
        
        [phase uphase] = get(grains,'phase');
      	ind = phase == get_option(varargin,'phase',uphase(1));
      
      elseif check_option(varargin,'CheckPhase')

        [phase uphase] = get(grains,'phase');
        warning('MTEX:MultiplePhases','This operatorion is only permitted for a single phase! I''m going to process only the first phase.');
        ind = phase == uphase(1);

      else

        ind = true(size(grains));

      end
      
      varargout{1} = [grains(ind).orientation];
      
      if nargout > 1
        varargout{2} = ind;
      end
      
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
     error(['There is no ''' vname ''' property in the ''grain'' object'])
  end
else
  vnames = get_obj_fields(grains(1),'properties');
  if nargout, varargout{1} = vnames; else disp(vnames), end
end
