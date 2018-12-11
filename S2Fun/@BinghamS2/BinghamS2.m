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
      % Input
      %  Z -  smoothing parameters;
      %       Z(1)>=Z(2)>=Z(3), Z(3)<0
      %       Z(1)=Z(2)  rotationally symmetric unimodal distribution
      %       Z(1)<<Z(2) partial girdle distribution
      %
      %  a -  principle axes (3 orthogonal vector3d) i.e.
      %       vector3d(rotation.matrix)
      %
      % Output
      %  BS2 - @BinghamS2 spherical Bingham distribution
      
      BS2.Z = Z;
      
      if nargin == 1
        BS2.a = [vector3d.X;vector3d.Y;vector3d.Z];
      else
        BS2.a = a;
      end
      
      % compute normalization constant
      BS2.N = 4*pi./BS2.normalizationConst;
    end
    
    
    function value = eval(BS2,v)
      % evaluate spherical Bingham distribution
      value = BS2.N * exp(dot_outer(v,BS2.a).^2 * BS2.Z(:));
    end
    
    
    function N = normalizationConst(BS2)   % needs esternal mex
      %   calc normalization parameter
      N = numericalSaddlepointWithDerivatives(sort(-BS2.Z(:))+1)*exp(1);
      N = N(3);
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
      %
      % Option
      %  ConfElli - specify the level p (default at 0.95)
      %             for the confidence ellipse for the mean direction
      %             based on Tanaka (1999) https://doi.org/10.1186/BF03351601
      %
      
      
      [a,kappa] = eig3(v*v);
      kappa = kappa./sum(kappa);
      Z =estimateZ(kappa);
      BS2 = BinghamS2(Z, a);
      BS2.N = BS2.normalizationConst;
      
      % add the estimate of confidence level, given as ellipse half
      % axes e.g.
      % plot(v)
      % ellipse(rotation('matrix',BS2.a.xyz'),BS2.cEllipse(1),BS2.cEllipse(2))
      p = get_option(varargin,'ConfElli',0.95);
      J = sqrt(chi2inv(p,2))/2;
      BS2.cEllipse = [J/(-Z(2)*(kappa(3)-kappa(2))), ...
        J/(-Z(1)*(kappa(3)-kappa(1)))];
      
      function Z = estimateZ(kappa)
        % adapted from https://github.com/libDirectional/libDirectional
        % Igor Gilitschenski, Gerhard Kurz, Simon J. Julier, Uwe D. Hanebeck,
        % Efficient Bingham Filtering based on Saddlepoint Approximations, 2014
        % Proceedings of the 2014 IEEE International Conference on Multisensor Fusion and Information Integration (MFI 2014), Beijing, China, September 2014.
        
        f = @(z) findZ(z, kappa);
        Z = fsolve(f, -ones(2,1), optimset('display', 'off', 'algorithm', 'levenberg-marquardt'));
        Z = [Z; 0];
        [Z, order] = sort(Z,'ascend');
        
        function R = findZ(Z, rhs)  % needs esternal mex
          Z=[Z;0];
          d = size(Z,1);
          
          % normalization constant
          A = numericalSaddlepointWithDerivatives(sort(-Z)+1)*exp(1);
          A = A(3);
          
          % derivative of normalization constant
          B = zeros(1,3);
          dim = size(Z,1);
          for i=1:dim
            mZ = Z([1:i i i:dim]);
            T = numericalSaddlepointWithDerivatives(sort(-mZ)+1)*exp(1)/(2*pi);
            B(i) = T(3);
          end
          
          R = zeros(d-1,1);
          for i=1:(d-1)
            R(i) = B(i)/A - rhs(i);
          end
        end
      end
      
    end
    
  end
end
