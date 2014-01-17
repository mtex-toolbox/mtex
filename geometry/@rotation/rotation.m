classdef rotation < quaternion & dynOption
% defines an rotation
%
% Syntax
%   rot = rotation('Euler',phi1,Phi,phi2) -
%   rot = rotation('Euler',alpha,beta,gamma,'ZYZ') -
%   rot = rotation('axis,v,'angle',omega) -
%   rot = rotation('matrix',A) -
%   rot = rotation('map',u1,v1) -
%   rot = rotation('map',u1,v1,u2,v2) -
%   rot = rotation('fibre',u1,v1,'resolution',5*degree) -
%   rot = rotation('quaternion',a,b,c,d) -
%   rot = rotation(q) -
%
% Input
%  q         - @quaternion
%  u1,u2     - @vector3d
%  v, v1, v2 - @vector3d
%  name      - {'brass','goss','cube'}
%
% Ouptut
%  rot - @rotation
%
% See also
% quaternion_index orientation_index

  properties
    i = []; % is inversion    
  end
  
  methods
    function rot = rotation(varargin)

      if nargin == 0, return;end

      if isa(varargin{1},'rotation') % copy constructor
        rot.a = varargin{1}.a;
        rot.b = varargin{1}.b;
        rot.c = varargin{1}.c;
        rot.d = varargin{1}.d;
        rot.i = varargin{1}.i;
        return
      end
        
      switch class(varargin{1})        

        case {'quaternion','double'}
       
          quat = varargin{1};
    
        case 'char'

          switch lower(varargin{1})
            
            case 'axis' % orientation by axis / angle
              quat = axis2quat(get_option(varargin,'axis'),get_option(varargin,'angle'));

            case 'euler' % orientation by Euler angles
              quat = euler2quat(varargin{2:end});

            case 'map'
        
              if nargin==5
                quat = vec42quat(varargin{2:end});
              else
                quat = hr2quat(varargin{2:end});
              end

            case 'quaternion'
           
              quat = quaternion(varargin{2:end});

            case 'rodrigues'
              
              quat = rodrigues2quat(varargin{2});
              
            case 'matrix'
              
              quat = mat2quat(varargin{2:end});

            case 'fibre'
           
              quat = fibre2quat(varargin{2:end});

            case 'inversion'
        
              quat = idquaternion;
              rot.i = true;
        
            case {'mirroring','reflection'}
        
              quat = axis2quat(varargin{2},pi);
              rot.i = true(size(quat));
        
            case 'random'
           
              quat = randq(get_option(varargin,'points',1));

            otherwise
              
              return
          end

        otherwise
          error('Type mismatch in rotation!')
      end
   
      [rot.a,rot.b,rot.c,rot.d] = double(quat);
      if isempty(rot.i), rot.i = false(size(quat));end
   
    end
  end
end
