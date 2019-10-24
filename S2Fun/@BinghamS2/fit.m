function BS2 = fit(v,varargin)
% function to fit Bingham parameters
%
% Description
% confidence ellipse for the mean direction based on Tanaka
% (1999) https://doi.org/10.1186/BF03351601
%
% Syntax
%   BS2 = BinghamS2.fit(v)
%
% Input
%  v - vector3d
%
% Output
%  BS2 - @BinghamS2
%
%
% Options
%  ConfElli - confidence level p (default at 0.95)
%
%
% Example
%
%   % simulate some directions
%   odf = unimodalODF(quaternion.id,'halfwidth',10*degree);
%   N = 100;
%   v = odf.discreteSample(N) .* ...
%     rotation.byAxisAngle(vector3d.X,rand(N,1)*2*pi) * vector3d.Y;
%
%   % fit a Bingham distribution
%   S2F = BinghamS2.fit(v)
%
%   % visualization
%   plot(S2F)
%   mtexColorMap LaboTeX
%   hold on
%   plot(t,'Markercolor','k','MarkerSize',3)
%   hold off
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
    [Z, ~] = sort(Z,'ascend');
    
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
