classdef SO3FunHomochoric < SO3Fun
% a class representing a function on SO(3) by values on a homochoric grid
%
% The function is given by one coefficient per cell of a homochoric grid
% and is piecewise constant on those cells. Since the grid allows to look
% up the cell of an orientation directly, evaluation is O(1) - which is
% what makes this representation useful for kernel density estimation from
% many individual orientations.
%
% Syntax
%   SO3F = SO3FunHomochoric(S3G,c)
%
% Input
%  S3G - @homochoricSO3Grid
%  c   - coefficient for each grid cell
%
% Output
%  SO3F - @SO3FunHomochoric
%
% Class Properties
%  S3G        - @homochoricSO3Grid
%  c          - coefficients
%  bandwidth  - harmonic degree used when converting to @SO3FunHarmonic
%  SRight, CS - @symmetry of the grid, acting from the right
%  SLeft, SS  - @symmetry of the grid, acting from the left
%
% See also
% SO3Fun homochoricSO3Grid SO3FunRBF

  properties
    S3G % homochoric orientation grid
    c   % coefficients
    bandwidth = 64; % harmonic degree
  end

  properties (Dependent = true)
    antipodal
    SLeft
    SRight
    isReal
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
        S = specimenSymmetry.default;
      end
    end
    
    function SO3F = set.SLeft(SO3F,S)
      SO3F.S3G.SS = S;
    end
    
    function S = get.SLeft(SO3F)
      try
        S = SO3F.S3G.SS;
      catch
        S = specimenSymmetry.default;
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
    
    function out = get.isReal(f)
      out = isreal(f.c);
    end
  
    function F = set.isReal(F,value)
      if ~value, return; end
      F.c = real(F.c);
    end
    
  end
end
