classdef BinghamS2 < S2Fun
  
  properties
    a      % principle axes
    Z      % smoothing parameters;
  end
  
  properties (SetAccess=protected)
    N = 1   % normalization constant
    antipodal = 1
    cEllipse = []
  end
  
  
  methods
    function BS2 = BinghamS2(Z,a)
      %
      % Description
      %  defines a spherical Bingham distribution with shape parameters |Z|
      %  and principal axes |a|. 
      %  Z(1)>=Z(2)>=Z(3), Z(3)<0
      %  Z(1)=Z(2)  rotationally symmetric unimodal distribution
      %  Z(1)<<Z(2) partial girdle distribution
      %
      % Syntax
      %
      %   BS2 = BinghamS2(Z,a)
      %
      % Input
      %  Z -  shape parameters
      %  a -  principle axes @vector3d
      %
      % Output
      %  BS2 - @BinghamS2 spherical Bingham distribution
      
      BS2.Z = Z;
      
      if nargin == 1
        BS2.a = [vector3d.X;vector3d.Y;vector3d.Z];
      else
        BS2.a = a.normalize;
      end
      
      % compute normalization constant
      BS2.N = 4*pi./BS2.normalizationConst;
    end
    
    
    function value = eval(BS2,v)
      % evaluate spherical Bingham distribution
      value = BS2.N * exp(dot_outer(v.normalize,BS2.a).^2 * BS2.Z(:));
    end
    
    
    function N = normalizationConst(BS2)   % needs esternal mex
      %   calc normalization parameter
      N = numericalSaddlepointWithDerivatives(sort(-BS2.Z(:))+1)*exp(1);
      N = N(3);
    end
    
  end
  
  methods (Static = true)
    
    BS2 = fit(v,varargin)
    
  end
end
