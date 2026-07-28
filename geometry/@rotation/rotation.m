classdef rotation < quaternion & dynOption
  % 
  % The class *rotation* allows to work with three dimensional orthogonal
  % matrices.
  %
  % Syntax
  %   rot = rotation.byEuler(phi1,Phi,phi2)
  %   rot = rotation.byEuler(alpha,beta,gamma,'ZYZ')
  %   rot = rotation.byAxisAngle(v,omega)
  %   rot = rotation.byMatrix(A)
  %   rot = rotation.map(u1,v1)
  %   rot = rotation.map(u1,v1,u2,v2)
  %   rot = reflection(b)
  %   rot = rotation.inversion
  %   rot = reflection(n)
  %   rot = rotation.byRodrigues(v)
  %   rot = rotation(fibre(u1,v1),'resolution',5*degree)
  %   rot = rotation(a,b,c,d)
  %
  % Input
  %  phi1, Phi, phi2 - Euler angles
  %  u1, u2          - @vector3d
  %  v, v1, v2       - @vector3d
  %  n               - @vector3d
  %  a,b,c,d         - quaternion components
  %
  % Output
  %  rot - @rotation
  %
  % Class Properties
  %  phi1, Phi, phi2 - Euler angles
  %  i               - inversion
  %  a, b, c, d      - quaternion components
  %
  % See also
  % RotationDefinition  RotationOperations RotationPlotting
  %

  properties
    i = []; % 0 stands for proper rotation, 1 for improper rotation
  end

  properties (Dependent = true)
    phi1  % Bunge Euler angle 1
    Phi   % Bunge Euler angle 2
    phi2  % Bunge Euler angle 3
  end

  methods
    function rot = rotation(varargin)
    
      if nargin == 0

      elseif isnumeric(varargin{1})
        
        rot.a = varargin{1};
        rot.b = varargin{2};
        rot.c = varargin{3};
        rot.d = varargin{4};
        rot.i = false(size(varargin{1}));

      elseif isa(varargin{1},'quaternion')

        [rot.a,rot.b,rot.c,rot.d, rot.i] = double(varargin{1});
     
      end
      
    end

    function phi1 = get.phi1(rot)
      [phi1,~,~] = Euler(rot,'Bunge');
    end

    function Phi = get.Phi(rot)
      [~,Phi,~] = Euler(rot,'Bunge');
    end

    function phi2 = get.phi2(rot)
      [~,~,phi2] = Euler(rot,'Bunge');
    end

    function alpha = alpha(rot)
      [alpha,~,~] = Euler(rot,'Matthies');
    end

    function beta = beta(rot)
      [~,beta,~] = Euler(rot,'Matthies');
    end
 
    function gamma = gamma(rot) 
      % This can not be a property since SO3Grid allready has the property gamma
      [~,~,gamma] = Euler(rot,'Matthies');
    end
  end

  methods (Static = true)

    r = nan(varargin);

    r = id(varargin);

    r = rand(varargin);

    r = inversion(varargin);

    r = byMatrix(varargin);

    r = byEuler(varargin);

    r = byAxisAngle(varargin);
    
    r = byRodrigues(varargin);

    r = byHomochoric(varargin);

    r = map(varargin);
    
    r = fit(varargin);

    [rot,interface,options] = load(fname,varargin)
    
  end

end
