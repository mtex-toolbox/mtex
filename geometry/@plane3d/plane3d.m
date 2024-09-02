classdef plane3d < dynOption
%
% The class plane3d describes a pane in 3D space, given by
% the plane equation ax+by+cz=d (general form).
%
% Syntax
%   plane = plane3d(a,b,c,d)
%   plane = plane3d.byPoints(pts_list)
%   plane = plane3d.byNormalform(N,P0)
%
% Input
%  a,b,c,d  - cart. coordinates
%  pts_list - list of points within the plane @vector3d
%  N, P0    - Plane normal and point within plane @vector3d
%
% Output
%  plane - @plane3d
%
%
% Dependent Class Properties
%  N - normal vector
%
%
% See also
% vector3d

  properties 
    a = []; 
    b = []; 
    c = []; 
    d = [];
    plottingConvention = plottingConvention
  end
    
  properties (Dependent = true)
    N   % normal vector
  end
  
  methods
    
    function plane = plane3d(varargin)
      % constructor of the class vector3d
      
      if nargin >=4 && isnumeric(varargin{1})
        
        plane.a = varargin{1};
        plane.b = varargin{2};
        plane.c = varargin{3};
        plane.d = varargin{4};

        if sum(abs([plane.a,plane.b,plane.c])) == 0
          error('at least one parameter must not be 0')
        end
      
      elseif nargin <= 1 & size(varargin{1},2)>=4
        abc = varargin{1};

        plane.a = abc(:,1);
        plane.b = abc(:,2);
        plane.c = abc(:,3);
        plane.d = abc(:,4);

      else
        error('wrong numer or type of inputs')
                
      end
    end
    
    function normal = get.N(plane)
      normal = normalize(vector3d(plane.a,plane.b,plane.c));
    end
    
  end
  
  methods (Static = true)

    function plane = byPoints(d,varargin)
      if length(d) >= 3
        plane = byNormalform(perp(d),d(1),varargin{:});
      else
        error('Enter at least 3 points within the plane')
      end
    end

    function plane = byNormalform(N,P0,varargin)
      if isa(N,'vector3d')
        a = N.x;
        b = N.y;
        c = N.z;
        d = sum(N.xyz.*P0.xyz,2);
        plane = plane3d(a,b,c,d, varargin{:});
      else
        error('Enter normal and P0 as vector3d')
      end
    end
    
  end
end
