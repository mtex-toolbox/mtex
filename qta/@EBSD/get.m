function varargout = get(ebsd,vname,varargin)
% extract data from a Pole Figure object
%
% Syntax
%   d = get(ebsd,'orientations')  - returns individuel orientations of the EBSD data
%   s = get(ebsd,'CS')            - returns its crystal symmetry
%   x = get(ebsd,'x')             - returns its spatial x coordinates
%   y = get(ebsd,'y')             - returns its spatial y coordinates
%   p = get(ebsd,'property')      - properties associated with the orientations
%   m = get(ebsd,'mad')           - property field MAD, if MAD is a property
%
% Input
%  ebsd - @EBSD
%
% Options
%  phase - phase to consider
%
% Output
%  d - @orientation
%  s - @symmetry
%  x,y,p,m - double
%
% See also
% EBSD/set


properties = get_obj_fields(ebsd.prop);
options    = get_obj_fields(ebsd.opt);
if nargin == 1
  vnames = [properties;options;{'data';'quaternion';'orientations';'Euler';'mineral';'minerals'}];
  if nargout, varargout{1} = vnames; else disp(vnames), end
  return
end

switch lower(vname)
  case 'cs'
    
    if numel(ebsd.phase)==0 
      varargout{1} = [];
      return
    end
    
    varargout = ebsd.CS(ebsd.phase(1));
    
  case 'cscell'
    
    varargout{1} = ebsd.CS;
    
  case {'data','orientations','orientation'}
    
    % ensure single phase   
    [ebsd,cs] = checkSinglePhase(ebsd);
      
    varargout{1} = orientation(ebsd.rotations,cs);
     
  case 'mis2mean'
    
    % check only a single phase is involved
    if numel(unique(ebsd.phase)) > 1
      
      error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase!' ...
        'See ' doclink('xx','xx')  ...
        ' for how to restrict EBSD data to a single phase.']);
      
    elseif numel(ebsd.phase) == 0
      
      varargout{1} = [];
      
    else
      
      varargout{1} = orientation(ebsd.options.mis2mean,ebsd.CS{ebsd.phase(1)},ebsd.CS{ebsd.phase(1)});
      
    end
    
  case 'phases'
    
    varargout{1} = ebsd.phaseMap;
    
  case 'phase' 
    
    varargout{1} = ebsd.phase;  
    
  case {'quaternions','quaternion'}
    
    varargout{1} = quaternion(ebsd.rotations);
    
  case 'euler'
    
    % if only one phase
    if numel(unique(ebsd.phase)) == 1
      
      [varargout{1:nargout}] = Euler(get(ebsd,'orientations'),varargin{:});
      
    else
      
      q = get(ebsd,'quaternion');
      [varargout{1:nargout}] = Euler(q,varargin{:});
      
    end
    
  case {'xy','xz','yz','xyz'}
    
    varargout{1} = [];
    
    xyz = num2cell(lower(vname));
    if all(isfield(ebsd.options,xyz))
      for k = 1:numel(xyz)
        varargout{1} = [varargout{1},ebsd.options.(xyz{k})];
      end
    end
    
  case {'weight','weights'}
    
    if isfield(ebsd.prop, 'weight')
      w = ebsd.prop.weight;
      varargout{1} = w./sum(w(:));
    else
      varargout{1} = ones(length(ebsd),1)./length(ebsd);
    end
    
  case 'mineral'
    
    ph = unique(ebsd.phase);
    if numel(ph) > 1
      error('There is more then one phase! Use get(...,''minerals'') instead.');
    end
        
    isCS = cellfun('isclass',ebsd.CS,'symmetry');
    minerals(isCS) = cellfun(@(x) get(x,'mineral') ,ebsd.CS(isCS),'uniformoutput',false);
    minerals(~isCS) = ebsd.CS(~isCS);
    varargout{1} = minerals{ph};
    
  case 'minerals'
    
    isCS = cellfun('isclass',ebsd.CS,'symmetry');
    varargout{1}(isCS) = cellfun(@(x) get(x,'mineral') ,ebsd.CS(isCS),'uniformoutput',false);
    varargout{1}(~isCS) = ebsd.CS(~isCS);
    
  case 'properties'
    
    varargout{1} = ebsd.prop;
    
  case 'propertynames'
    
    varargout{1} = fieldnames(ebsd.prop);
    
  otherwise
    
    try %#ok<TRYNC>
      varargout{1} = ebsd.prop.(vname);
      return
    end
    
    try %#ok<TRYNC>
      varargout{1} = ebsd.opt.(vname);
      return
    end
    
    error(['There is no ''' vname ''' property in the ''EBSD'' object'])
end

