function rot = rotation(varargin)
% defines an rotation



%% empty constructor
if nargin == 0

  % empty quaternion;
  quat = quaternion;
      
%% copy constructor
elseif isa(varargin{1},'rotation')
        
  rot = varargin{1};
  return;

elseif isa(varargin{1},'quaternion') &&  ~isa(varargin{1},'symmetry')
  
  quat = varargin{1};
  
%% determine crystal and specimen symmetry
else
  
  %% orientation given by a quaternion
  
  args  = find(cellfun(@(s) isa(s,'quaternion') & ~isa(s,'symmetry'),varargin,'uniformoutput',true));
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
  
end

superiorto('quaternion','symmetry');
rot = class(struct([]),'rotation',quat);
