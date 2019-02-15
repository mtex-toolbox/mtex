classdef rotation < quaternion & dynOption
% defines an rotation
%
% Syntax
%   rot = rotation.byEuler(phi1,Phi,phi2) 
%   rot = rotation.byEuler(alpha,beta,gamma,'ZYZ') 
%   rot = rotation.axisAngle(v,omega) 
%   rot = rotation.matrix(A)
%   rot = rotation.map(u1,v1)
%   rot = rotation.map(u1,v1,u2,v2) 
%   rot = reflection(b)
%   rot = rotation.inversion 
%   rot = rotation.byRodrigues(v)
%   rot = rotation(fibre(u1,v1),'resolution',5*degree)
%   rot = rotation(quaternion(a,b,c,d))
%
% Input
%  u1,u2     - @vector3d
%  v, v1, v2 - @vector3d
%  n         - @vector3d
%
% Ouptut
%  rot - @rotation
%
% See also
% quaternion_index orientation_index

  properties
    i = []; % 0 stands for proper rotation, 1 for improper rotation
  end

  properties (Dependent = true)
    phi1 % Bunge Euler angle 1
    Phi  % Bunge Euler angle 2
    phi2 % Bunge Euler angle 3
  end

  methods
    function rot = rotation(varargin)

      if nargin == 0, return;end
      
      if isa(varargin{1},'quaternion')  % copy constructor
        
        [rot.a,rot.b,rot.c,rot.d] = double(varargin{1});
        try
          rot.i = varargin{1}.i;
        catch
          rot.i = false(size(rot.a));
        end
        return
      end
        
      switch class(varargin{1})
        
        case 'double'
        
          rot.a = varargin{1};
          rot.b = varargin{2};
          rot.c = varargin{3};
          rot.d = varargin{4};

        case 'char'

          switch lower(varargin{1})

            case 'axis' % orientation by axis / angle
              
              rot = rotation.byAxisAngle(get_option(varargin,'axis'),get_option(varargin,'angle'));
              
            case 'euler' % orientation by Euler angles
              
              rot = rotation.byEuler(varargin{2:end});

            case 'map'

              rot = rotation.map(varargin{2:end});
              
            case 'quaternion'

              rot = rotation(quaternion(varargin{2:end}));

            case 'rodrigues'

              rot = rotation.byRodrigues(varargin{2});

            case 'matrix'

              rot = rotation.byMatrix(varargin{2:end});              

            case {'mirroring','reflection'}

              rot = reflection(varargin{:});
              
            otherwise

              error('Wrong rotation syntax!')
          end

        otherwise
          error('Type mismatch in rotation!')
      end
      
    end

    function phi1 = get.phi1(rot)
      [phi1,~,~] = Euler(rot);
    end

    function Phi = get.Phi(rot)
      [~,Phi,~] = Euler(rot);
    end

    function phi2 = get.phi2(rot)
      [~,~,phi2] = Euler(rot);
    end

  end

  methods (Static = true)

    function r = nan(varargin)
      r = rotation(quaternion.nan(varargin{:}));
    end

    function r = id(varargin)
      r = rotation(quaternion.id(varargin{:}));
    end

    function r = rand(varargin)
      r = rotation(quaternion.rand(varargin{:}));
    end

    function r = inversion(varargin)
      r = rotation.id(varargin{:});
    end

    r = byMatrix(varargin);

    r = byEuler(varargin);

    r = byAxisAngle(varargin);
    
    r = byRodrigues(varargin);

    r = map(varargin);

    [rot,interface,options] = load(fname,varargin)
    
  end

end
