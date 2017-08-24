classdef dislocationSystem < slipSystem
% class representing dislocation systems
%
% Syntax
%   dS = slipSystem(b,l)
%
% Input
%  b - @Miller Burgers vector
%  l - @Miller line of dislocations
%
  
  properties (Dependent = true)
    l % 
  end
  
  methods
    function dS = dislocationSystem(b,l)
      
      dS.b = b;
      dS.n = l;
    
      dS.CRSS = ones(size(dS.b));
      
    end
      
    function l = get.l(dS)
      l = dS.n;
    end
    
    function dS = set.l(dS,l)
      dS.n = l;
    end
    
  end
  
  methods (Static = true)
    
    function dS = fcc(cs,varargin)
      dS = dislocationSystem(...
        [Miller(-1,1,0,cs,'uvw'),Miller(1,1,0,cs,'uvw')],...
        [Miller(1,1,1,cs,'hkl'),Miller(1,1,0,cs,'hkl')],varargin{:});
    end
    
    function dS = bcc(cs,varargin)
      
      dS = dislocationSystem(...
        [Miller(1,1,1,cs,'uvw'),Miller(1,1,1,cs,'uvw'),...
        Miller(1,1,1,cs,'uvw'),Miller(1,1,1,cs,'uvw')],...
        [Miller(1,-1,0,cs,'hkl'),Miller(-1,-1,2,cs,'hkl'),...
        Miller(-3,2,1,cs,'hkl'),Miller(1,1,1,cs,'hkl')],varargin{:});
    end
    
  end
end