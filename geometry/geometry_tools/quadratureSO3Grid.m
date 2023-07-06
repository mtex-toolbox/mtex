function [SO3G, W] = quadratureSO3Grid(bandwidth, varargin)
% nodes and weights for quadrature on SO(3)
%   'ClenshawCurtis'  - combinate the Gauss quadrature in 1st and 3rd Euler angle 
%                       (alpha, gamma) with Clenshaw Curtis quadrature in 2nd 
%                       Euler angle (beta)
%
% Syntax
%   [SO3G, W, M2] = quadratureSO3rid(M, 'ClenshawCurtis') quadrature grid of type Clenshaw Curtis
%


if check_option(varargin, 'gauss') || check_option(varargin, 'chebyshev')
  warning('Quadrature of types gauss and chebychev are not implemented yet.')
  return
end

% TODO: Use Gauß-Legendre quadrature
% if check_option(vargin,'gauss')
% 
%   return
% end


if check_option(varargin,'ClenshawCurtis')
  SO3G = regularSO3Grid('ClenshawCurtis','bandwidth',bandwidth,varargin{:},'ABG');

  w = fclencurt2(bandwidth+1);
  if size(SO3G,2) == 1+bandwidth/2
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


