function [SO3G, W] = quadratureSO3Grid(N, varargin)
% Compute nodes and weights for quadrature on SO(3). Therefore the
% following quadrature rules are implemented yet:
%
%   'ClenshawCurtis'  - combinate the Gauss quadrature in 1st and 3rd Euler angle 
%                       (alpha, gamma) with Clenshaw Curtis quadrature in 2nd 
%                       Euler angle (beta)
%   'GaussLegendre'   - combinate the Gauss quadrature in 1st and 3rd Euler angle 
%                       (alpha, gamma) with Gauss Legendre quadrature in 2nd 
%                       Euler angle (beta)
%
% Syntax
%   SO3G = quadratureSO3rid(N, 'ClenshawCurtis')
%   [SO3G, W] = quadratureSO3rid(N,CS,SS,'ClenshawCurtis') % quadrature grid of type Clenshaw Curtis
%
% Input
%  N - bandwidth
%  CS,SS  - @symmetries
%
% Output
%  SO3G - @orientation grid
%  W - quadrature weights
%
% Options
%  ClenshawCurtis - use Clenshaw Curtis quadrature nodes and weights
%  GaussLegendre - use Gauss Legendre quadrature nodes and weights (not implemented yet)
%
% See also
% regularSO3Grid  SO3FunHarmonic/quadrature



if check_option(varargin, 'gauss') || check_option(varargin, 'chebyshev')
  warning('Quadrature of types gauss and chebychev are not implemented yet.')
  return
end

% Do not use 'antipodal' for evaluation or quadrature grid
varargin = delete_option(varargin,'antipodal');

% The quadrature method itself only uses Z-fold rotational symmetry axis
% (only use cyclic symmetry axis)
[SRight,SLeft] = extractSym(varargin);
sym = {'1','112','3','4','','6'};
if isa(SRight,'crystalSymmetry')
  SRightNew = crystalSymmetry(sym{SRight.multiplicityZ});
else
  SRightNew = specimenSymmetry(sym{SRight.multiplicityZ});
end
if isa(SLeft,'crystalSymmetry')
  SLeftNew = crystalSymmetry(sym{SLeft.multiplicityZ});
else
  SLeftNew = specimenSymmetry(sym{SLeft.multiplicityZ});
end


% TODO: Use Gauß-Legendre quadrature
if check_option(varargin,'GaussLegendre')
  
  SO3G = regularSO3Grid('GaussLegendre','bandwidth',N,SRightNew,SLeftNew,varargin{:},'ABG');
  SO3G.CS = SRight; SO3G.SS = SLeft;

  % Weights
  [~,w] = legendreNodesWeights(N/2+1,-1,1);
  W = repmat(w'/(2*size(SO3G,1)*size(SO3G,3)),size(SO3G,1),1,size(SO3G,3));

end


if check_option(varargin,'ClenshawCurtis')

  SO3G = regularSO3Grid('ClenshawCurtis','bandwidth',N,SRightNew,SLeftNew,varargin{:},'ABG');
  SO3G.CS = SRight; SO3G.SS = SLeft;

  % Weights
  w = fclencurt2(N+1);
  if size(SO3G,2) == 1+N/2
    w = w(1:size(SO3G,2));
  end
  % W = normalized volume * 2xGauß-quadrature-weights * Clenshaw-Curtis-quadrature-weights
  % W =     1/sqrt(8*pi^2)    *      (2*pi/(2*N+2))^2     *              w_b^N
  W = 1/(2*size(SO3G,1)*size(SO3G,3))*repmat(w',size(SO3G,1),1,size(SO3G,3));


end

end

function w = fclencurt2(n)

  c = zeros(n,2);
  c(1:2:n,1) = (2./[1 1-(2:2:n-1).^2 ])';
  c(2,2)=1;
  f = real(ifft([c(1:n,:);c(n-1:-1:2,:)]));
  w = 2*([f(1,1); 2*f(2:n-1,1); f(n,1)])/2;
  %x = 0.5*((b+a)+n*bma*f(1:n1,2));

end


