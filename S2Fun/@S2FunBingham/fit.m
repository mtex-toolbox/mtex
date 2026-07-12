function [BS2,ab,rot] = fit(v,varargin)
% function to fit Bingham parameters
%
% Description
% confidence ellipse for the mean direction based on Tanaka /
% asymptotic covariance of the maximum eigenvector
% (1999) https://doi.org/10.1186/BF03351601
%
% Syntax
%   BS2 = S2FunBingham.fit(v)
%   [BS2, ab, rot] = S2FunBingham.fit(v,'p',0.95)
%
% Input
%  v - vector3d
%
% Output
%  BS2 - @S2FunBingham
%  ab  - semi axes length of the confidence ellipse (in radian)
%  rot - orientation of the confidence ellipse, to be used with |ellipse|
%
% Options
%  p - confidence level p of the ellipse computed (default at 0.95)
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
%   [S2F, ab, rot] = S2FunBingham.fit(v)
%
%   % visualization
%   plot(S2F)
%   mtexColorMap LaboTeX
%   hold on
%   plot(v,'Markercolor','k','MarkerSize',3)
%   ellipse(rot,ab(1),ab(2))
%   hold off
%

[a,kappa] = eig3(v*v);


% normalize eigenvalues to obtain the eigenvalues of the scatter matrix
kappa = kappa./sum(kappa);

Z =estimateZ(kappa);
BS2 = S2FunBingham(Z, a);
BS2.N = BS2.normalizationConst;

if nargout <= 1, return; end

% estimate of confidence level, given as ellipse half axes, e.g.
% plot(v)
% ellipse(rot,ab(1),ab(2))
p = get_option(varargin,'p',0.95);

% compute
N = length(v);

% sample directions in the principal coordinate system
Y = v.xyz * a.xyz;

% 4-order moments estimated for the covariance of the max eigenvector
m1133 = mean(Y(:,1).^2 .* Y(:,3).^2);
m2233 = mean(Y(:,2).^2 .* Y(:,3).^2);
m1233 = mean(Y(:,1).*Y(:,2).*Y(:,3).^2);


% asymptotic covariance matrix of the max eigenvector in the
% tangent plane, given by the first two principal directions.
Sigma = zeros(2);
gap31 = (kappa(3)-kappa(1));
gap32 = (kappa(3)-kappa(2));

Sigma(1,1) = m1133/(N*gap31^2);
Sigma(2,2) = m2233/(N*gap32^2);
Sigma(1,2) = m1233/(N*gap31*gap32);
Sigma(2,1) = Sigma(1,2);

% principal axes of the covariance ellipse
[V,E] = eig(Sigma);

% semi-axis lengths of the confidence ellipse (in radians).
c = chi2inv(p,2);

ab = sqrt(c*diag(E)).';

% rotate the tangent-plane basis into the principal directions of the
% covariance ellipse while keeping the mean direction (third eigenvector)
% fixed.
A = a.xyz; B = A;
B(1:2,:) = V' * A(1:2,:);

rot = rotation.byMatrix(B');


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
