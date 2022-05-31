classdef SO3FunHomochoric < SO3Fun
% a class representing SO3Funs on a special grid

  properties
    S3G % homochoric orientation grid
    c   % coefficients
  end

  properties (Dependent = true)
    bandwidth % harmonic degree
    antipodal
    SLeft
    SRight
  end
  
  methods
    
    function SO3F = SO3FunHomochoric(S3G,c)
                 
      if nargin == 0, return;end
      
      SO3F.S3G = S3G;
      SO3F.c   = c;
            
    end

    
    function SO3F = set.SRight(SO3F,S)
      SO3F.S3G.CS = S;
    end
    
    function S = get.SRight(SO3F)
      try
        S = SO3F.S3G.CS;
      catch
        S = specimenSymmetry;
      end
    end
    
    function SO3F = set.SLeft(SO3F,S)
      SO3F.S3G.SS = S;
    end
    
    function S = get.SLeft(SO3F)
      try
        S = SO3F.S3G.SS;
      catch
        S = specimenSymmetry;
      end
    end
    
    function SO3F = set.antipodal(SO3F,antipodal)
      SO3F.S3G.antipodal = antipodal;
    end
        
    function antipodal = get.antipodal(SO3F)
      try
        antipodal = SO3F.S3G.antipodal;
      catch
        antipodal = false;
      end
    end
    
    function L = get.bandwidth(SO3F)
      % should depend on the number of grid points
      L = 64;
    end
    
    function SO3F = set.bandwidth(SO3F,L)
      % this is not possible
    end
    
  end
end
