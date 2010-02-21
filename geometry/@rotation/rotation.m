function rot = rotation(varargin)
% defines an rotation
%
%% Syntax
%  rot = rotation('Euler',phi1,Phi,phi2)
%  rot = rotation('Euler',alpha,beta,gamma,'ZYZ')
%  rot = rotation('axis,v,'angle',omega)
%  rot = rotation('matrix',A)
%  rot = rotation('map',u1,v1,u2,v2)
%  rot = rotation('quaternion',a,b,c,d)
%  rot = rotation(q)
%
%% Input
%  q         - @quaternion
%  u1,u2     - @vector3d
%  v, v1, v2 - @vector3d
%  name      - {'brass','goss','cube'}
%
%% Ouptut
%  rot - @rotation
%
%% See also
% quaternion_index orientation_index

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
  
  if check_option(varargin,'map')
    args = find_option(varargin,'map');
    quat = vec42quat(varargin{(args+1):(args+4)});
  end
  
  if check_option(varargin,'quaternion')
    args = find_option(varargin,'quaternion');
    quat = quaternion(varargin{(args+1):(args+4)});
  end
  
  if check_option(varargin,'matrix')
    args = find_option(varargin,'matrix');
    quat = mat2quat(varargin{args+1});
  end
  
end

superiorto('quaternion','symmetry');
rot = class(struct([]),'rotation',quat);
