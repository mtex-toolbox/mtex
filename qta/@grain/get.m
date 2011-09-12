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
%  return ids and ids-list of neighbours
%   
%    mtexdata aachen
%    [grains ebsd] = segment2d(ebsd);
%
%    get(grains(1:2),'id')
%
%    get(grains(1:2),'neighbour')
%

if nargin > 1
  %assert_property(grains,vname);
  switch vname
    case 'comment'
      
      varargout{1} = populate(grains,vname);
      if numel( varargout{1}) == 1,
        varargout{1} = varargout{1}{1};
      end
      
    case 'CS'
      
      varargout = get(grains,'CSCell');
      
    case 'CSCell'
      
      [phase,uphase,id] = get(grains,'phase');
      
      sym = cell(size(id));
      for l=1:length(id)
        sym{l} = get(grains(id(l)).orientation,'CS');
      end
      varargout{1} = sym;
      
    case 'SS'
      
       varargout = get(grains,'SSCell');
   
    case 'SSCell'
      
      [phase,uphase,id] = get(grains,'phase');
      
      sym = cell(size(id));
      for l=1:length(id)
        sym{l} = get(grains(id(l)).orientation,'SS');
      end
      varargout{1} = sym;
      
    case 'mineral'
      
      CS = get(grains,'CSCell');
      for k=1:numel(CS)
        varargout{k} = get(CS{k},'mineral');
      end
      
    case 'minerals'
      
      CS = get(grains,'CSCell');
      for k=1:numel(CS)
        varargout{1}{k} = get(CS{k},'mineral');
      end
      
    case 'phase'

      varargout{1} = populate(grains,vname);
              
      if nargout > 1
        [varargout{2}, varargout{3}] = unique(varargout{1},'first');
      end
      
    case {'orientations','orientation'}
          
      if numel(unique([grains.phase])) > 1        
        error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase!' ...
        'See ' doclink('xx','xx')  ...
        ' for how to restrict grains to a single phase.']);
      end
               
      varargout{1} = [grains.orientation];

    case {'quaternion','quaternions'}
                              
      varargout{1} = quaternion([grains.orientation]);

      
    case fields(grains)
      
      varargout{1} = populate(grains,vname);
      
    case fields(grains(1).properties)
      
      p = [grains.properties];
      varargout{1} = [p.(vname)];
      
    otherwise
      error(['There is no ''' vname ''' property in the ''grain'' object'])
  end
else
  vnames = get_obj_fields(grains(1),'properties');
  if nargout, varargout{1} = vnames; else disp(vnames), end
end



function out = populate(struc, field)

p = strcmpi(field, fieldnames(struc));

struc = struct2cell(struc);
struc = squeeze(struc(p,:,:));

if ~isempty(struc) && all(cellfun('prodofsize',struc) == 1)
  
  if isnumeric(struc{end})    % the whole thing should be numeric, otherwise error
    
    out = zeros(size(struc));   
    
  elseif isstruct(struc{end})
    
    out = repmat(struc{1},size(struc));
    
  else
    
    out = horzcat(struc{:});
    return
    
  end
  
  for k=1:numel(out) % copy
    out(k) = struc{k};
  end
  
elseif iscell(struc) && (isempty_cell(struc) || isempty(struc{1}))
  
  out = [];
  
else
  out = struc;
end




