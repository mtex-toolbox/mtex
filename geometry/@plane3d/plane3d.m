classdef plane3d < dynOption
%
% The class plane3d describes a pane in 3D space, given by
% the plane equation N.v = d
%
% Syntax
%   plane = plane3d(N,d)
%   plane = plane3d(N,v0)
%   plane = plane3d.byPoints(v)
%
% Input
%  N - normal direction @vector3d
%  d - distance to origin
%  v0, v - @vector3d 
%
% Output
%  plane - @plane3d
%
% See also
% vector3d

properties
  N % normal direction
  d % distance to origin
end
  
methods
    
  function plane = plane3d(N,d,varargin)
    % constructor of the class vector3d
    
    if isa(N,'vector3d')
      
      plane.N = normalize(N);
      
      if nargin>1 && isnumeric(d)
        plane.d = d ./ norm(N);
      elseif nargin>1 && isa(d,'vector3d')
        plane.d = dot(plane.N,d);
      else
        plane.d = zeros(size(N));
      end

    elseif isa(N,'plane3d')
      plane = N;
    end
  end
    
end
  
methods (Static = true)

  function plane = byPoints(d,varargin)
    if length(d) >= 3
      plane = plane3d(perp(d),d(1),varargin{:});
    else
      error('Enter at least 3 points within the plane')
    end
  end
end
end
