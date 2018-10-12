classdef BinghamS2 < S2Fun
  
  properties
    a      % principle axes
    kappa  % eigen values
  end
  
  properties (SetAccess=protected)
    N = 1 % normalization constant
  end
  
  
  methods
    function BS2 = BinghamS2(kappa,a)
      %
      % Input
      %  kappa - 
      %  a
      %
      % Output
      %  BS2 - @BinghamS2 spherical Bingham distribution
      
      BS2.kappa = kappa;
      
      if nargin == 1
        BS2.a = [vector3d.X;vector3d.Y;vector3d.Z];
      else
        BS2.a = a;
      end
      
      % compute normalization constant
      BS2 = updateNormalization(BS2);
      
    end
    
    function value = eval(BS2,v)
    % evaluate spherical Bingham distribution 
    
      value = BS2.N * exp(dot_outer(v,BS2.a).^2 * BS2.kappa(:));
      
    end
    
    function m = mean(BS2)
    
      % mean should be simple sum of kappa's if correctly normalized
      m = sum(BS2.kappa);
    end
    
    
  end

methods (Static = true)
  
  function BS2 = fit(v)
    % function to fit Bingham parameters
    %
    % Syntax
    %   %   BS2 = BinghamS2.fit(v)
    %
    % Input
    %  v - vector3d
    %
    % Output
    %  BS2 - @BinghamS2
    %
    
    [a,kappa] = eig3(v*v);
    
    BS2 = BinghamS2(kappa ./ sum(kappa), a);    
    
  end
end

methods
  
  function BS2 = updateNormalization(BS2)
    % adapted from https://github.com/libDirectional/libDirectional
    % Igor Gilitschenski, Gerhard Kurz, Simon J. Julier, Uwe D. Hanebeck,
    % Efficient Bingham Filtering based on Saddlepoint Approximations, 2014
    % Proceedings of the 2014 IEEE International Conference on Multisensor Fusion and Information Integration (MFI 2014), Beijing, China, September 2014.
    
    f = @(z) findNormalizationConst(z, BS2.kappa);
    Z = fsolve(f, -ones(2,1), optimset('display', 'off', 'algorithm', 'levenberg-marquardt'));
    Z = [Z; 0];
    [Z, order] = sort(Z,'ascend');

    % TODO: this should somehow become the normalization constant
    BS2.N = sum(Z);
    
    
    
    function R = findNormalizationConst(Z, rhs)  % need esternal mex
      Z=[Z;0];
      % objective function of MLE.
      d = size(Z,1);
    
      % normalization constant
      a = numericalSaddlepointWithDerivatives(sort(-Z)+1)*exp(1);
      a = a(3);
    
      % derivative of normalization constant
      b = zeros(1,3);
      dim = size(Z,1);
      for i=1:dim
        mZ = Z([1:i i i:dim]);
        T = numericalSaddlepointWithDerivatives(sort(-mZ)+1)*exp(1)/(2*pi);
        b(i) = T(3);
      end
    
      R = zeros(d-1,1);
      for i=1:(d-1)
        R(i) = b(i)/a - rhs(i);
      end
    end
  end
end

end