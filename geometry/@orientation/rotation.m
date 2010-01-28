function rot = rotation(varargin)
% defines an rotation

% empty quaternion;
quat = quaternion;

%% empty constructor
if nargin == 0
  
  rot.i = [];
  
%% copy constructor
elseif isa(varargin{1},'rotation')
        
  rot = varargin{1};
  return;

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
  
  rot.i = ones(size(quat));
end

superiorto('quaternion');
rot = class(rot,'rotation',quat);
