function varargout = get(ebsd,vname,varargin)
% extract data from a Pole Figure object
%
%% Syntax
%  d = get(ebsd,'orientations')  - returns individuel orientations of the EBSD data
%  s = get(ebsd,'CS')            - returns its crystal symmetry
%  x = get(ebsd,'x')             - returns its spatial x coordinates
%  y = get(ebsd,'y')             - returns its spatial y coordinates
%  p = get(ebsd,'property')      - properties associated with the orientations
%  m = get(ebsd,'mad')           - property field MAD, if MAD is a property
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  phase - phase to consider
%
%% Output
%  d - @orientation
%  s - @symmetry
%  x,y,p,m - double
%
%% See also
% EBSD/set


properties = get_obj_fields(ebsd);
options    = get_obj_fields(ebsd.options);
if nargin == 1
  vnames = [properties;{'data';'quaternion';'orientations';'Euler';'mineral';'minerals'}];
  if nargout, varargout{1} = vnames; else disp(vnames), end
  return
end

switch lower(vname)
  case 'cs'

    varargout = ebsd.CS;

  case 'cscell'

    varargout{1} = ebsd.CS;

  case {'data','orientations','orientation'}


    % check only a single phase is involved
    if numel(unique(ebsd.phase)) > 1

      error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase!' ...
        'See ' doclink('xx','xx')  ...
        ' for how to restrict EBSD data to a single phase.']);

    elseif numel(ebsd.phase) == 0

      varargout{1} = [];

    else

      varargout{1} = orientation(ebsd.rotations,ebsd.CS{ebsd.phase(1)},ebsd.SS);

    end

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

    varargout{1} = unique(ebsd.phase)';

  case lower(properties)

    varargout{1} = ebsd.(properties{find_option(properties,vname)});
  
  case lower(options)

    varargout{1} = ebsd.options.(options{find_option(options,vname)});

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
    
  case 'weight'

    if isfield(ebsd.options, 'weight')
      w = ebsd.options.weight;
      varargout{1} = w./sum(w(:));
    else
      varargout{1} = ones(numel(ebsd),1)./numel(ebsd);
    end

  case 'mineral'

    varargout = cellfun(@(x) get(x,'mineral') ,ebsd.CS,'uniformoutput',false);

  case 'minerals'

    varargout{1} = cellfun(@(x) get(x,'mineral') ,ebsd.CS,'uniformoutput',false);

  otherwise
    error(['There is no ''' vname ''' property in the ''EBSD'' object'])
end

