function o = orientation(varargin)
% defines an orientation

%% empty constructor
if nargin == 0
  
  o.cs = symmetry;
  o.ss = symmetry;
  o.i = 1;
  quat = quaternion;
  
  
%% copy constructor
elseif isa(varargin{1},'orientation')
        
  o = varargin{1};
  return;

%% determine crystal and specimen symmetry
else
  
  args  = find(cellfun(@(s) isa(s,'symmetry'),varargin,'uniformoutput',true));

  if length(args) >= 1
    o.cs = varargin{args(1)};
  else
    o.cs = symmetry;
  end

  if length(args) == 2
    o.ss = varargin{args(2)};
  else
    o.ss = symmetry;
  end
  
  if length(args) > 2, error('MTEX:orientation','to many symmetries specified');end
  
  %% orientation given by a quaternion
  
  args  = find(cellfun(@(s) isa(s,'quaternion'),varargin,'uniformoutput',true));
  if length(args) == 1
    quat = [varargin{args}];
  end
  
  %% orientation by axis / angle
  
  if check_option(varargin,'axis')
    quat = axis2quat(get_option(varargin,'axis'),get_option(varargin,'angle'));
  end
  
  %% orientation by Euler angles
  
  if check_option(varargin,'Euler')
    args = find_option(varargin,'Euler');
    quat = euler2quat(varargin{args+1},varargin{args+2},varargin{args+3},varargin{:});
  end

  if check_option(varargin,'Miller')
    
    args = find_option(varargin,'Miller');
    
    quat = Miller2quat(varargin{args+1},varargin{args+2},o.cs);
    
  end
  
  o.i = 1;
end

superiorto('quaternion','SO3Grid');
o = class(o,'orientation',quat);
