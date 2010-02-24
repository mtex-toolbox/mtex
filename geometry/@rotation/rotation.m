function rot = rotation(varargin)
% defines an rotation
%
%% Syntax
%  rot = rotation('Euler',phi1,Phi,phi2)
%  rot = rotation('Euler',alpha,beta,gamma,'ZYZ')
%  rot = rotation('axis,v,'angle',omega)
%  rot = rotation('matrix',A)
%  rot = rotation('map',u1,v1,u2,v2)
%  rot = rotation('fibre',u1,v2,'resolution',5*degree)
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

  quat = quaternion; % empty quaternion;
  superiorto('quaternion','symmetry');
  rot = class(struct([]),'rotation',quat);
  return
end  

switch class(varargin{1})       
  
  case 'rotation' 
    rot = varargin{1}; % copy constructor
    return;

  case 'quaternion'
    quat = varargin{1};
  
  case 'char'

    switch varargin{1}
      
      case 'axis' % orientation by axis / angle
         quat = axis2quat(get_option(varargin,'axis'),get_option(varargin,'angle'));
  
      case 'Euler' % orientation by Euler angles
         quat = euler2quat(varargin{2:end});

      case 'map'
        quat = vec42quat(varargin{2:end});
    
      case 'quaternion'
        quat = quaternion(varargin{2:end});
    
      case 'matrix'
        quat = mat2quat(varargin{2:end});
        
      case 'fibre'
        quat = fibre2quat(varargin{2:end});
        
      otherwise
        error('Unknown type of rotation!')
    end
    
  otherwise
    error('Type mismatch in rotation!')
end

superiorto('quaternion','symmetry');
rot = class(struct([]),'rotation',quat);
