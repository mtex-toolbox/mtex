classdef quaternion
%
% The class quaternion realizes the internal representation of rotations
% and orientations in MTEX. An important difference is that an unit
% quaternion *q* and its antipodal *-q* are considered as different while
% the corresponding rotations are equal.
%
% Syntax
%   q = quaternion(a,b,c,d)
%   q = quaternion.rand
%   q = quaternion.id
%   q = quaternion.nan
%
% Input
%  a, b, c, d - double
%
% Class Properties
%  a, b, c, d - quaternion coefficients
%
% See also
% rotation.rotation orientation.orientation
  
  properties
    a % real part
    b % * i
    c % * j
    d % * k
  end
  
  methods
    function q = quaternion(varargin)
      
      if nargin == 0, return;end
      
      if isa(varargin{1},'quaternion')   % copy constructor
              
        if nargin == 1
          q.a = varargin{1}.a;
          q.b = varargin{1}.b;
          q.c = varargin{1}.c;
          q.d = varargin{1}.d;
        else          
          q.a = varargin{1}.a(varargin{2:end});
          q.b = varargin{1}.b(varargin{2:end});
          q.c = varargin{1}.c(varargin{2:end});
          q.d = varargin{1}.d(varargin{2:end});
        end
      elseif isa(varargin{1},'vector3d')
          
        q.a = zeros(size(varargin{1}));
        [q.b,q.c,q.d] = double(varargin{1});
          
      elseif isnumeric(varargin{1})
          
        switch nargin
            
          case 1
              
            D = varargin{1};
              
            q.a = D(1,:); q.b = D(2,:); q.c = D(3,:); q.d = D(4,:);

            s = size(D);
            s = [1 s(2:ndims(D))];
            
            q = reshape(q,s);
              
          case 2
              
            if length(varargin{1}) ~= 1
              q.a = varargin{1};
            else
              q.a = repmat(varargin{1},size(varargin{2}));
            end
            
            [q.b,q.c,q.d] = double(varargin{2});
            
          case 4
            
            q.a = varargin{1};
            q.b = varargin{2};
            q.c = varargin{3};
            q.d = varargin{4};

        end
      end
      
    end
    
    function d = quat_dot(g1,g2)
      d = g1.a .* g2.a + g1.b .* g2.b + g1.c .* g2.c + g1.d .* g2.d;
    end

    function d = quat_dot_outer(g1,g2,varargin)

      if ~isempty(g1) && ~isempty(g2)

        q1 = [g1.a(:) g1.b(:) g1.c(:) g1.d(:)];
        q2 = [g2.a(:) g2.b(:) g2.c(:) g2.d(:)];
  
        d = q1 * q2';

      else
        d = [];
      end
    end

    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end
    
  end
  
  methods (Static = true)
    
    function q = nan(varargin)
      a = nan(varargin{:});
      q = quaternion(a,a,a,a);
    end
    
    function q = id(varargin)
      a = ones(varargin{:});
      b = zeros(varargin{:});
      q = quaternion(a,b,b,b);
    end
        
    function q = rand(varargin)
      
      if check_option(varargin,'maxAngle')
        
        v = vector3d.rand(varargin{:});
        
        omega = linspace(0,get_option(varargin,'maxAngle'),1e4);
        id = discretesample(sin(omega).^2,varargin{1});
        omega = omega(id);
        
        q = axis2quat(v,omega(:));
        
      else
        if nargin < 2, varargin = [varargin 1]; end

        alpha = 2*pi*rand(varargin{:});
        beta  = acos(2*(rand(varargin{:})-0.5));
        gamma = 2*pi*rand(varargin{:});

        q = euler2quat(alpha,beta,gamma);
      end
    end
    
  end
  
end
