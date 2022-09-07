function [SO3G, W, M2] = quadratureSO3Grid(bandwidth, varargin)
% Calculate the nodes and weights of specific quadrature grids on SO(3)
%   'ClenshawCurtis'  - combinate the Gauss quadrature in 1st and 3rd Euler angle 
%                       (alpha, gamma) with Clenshaw Curtis quadrature in 2nd 
%                       Euler angle (beta)
%
% Syntax
%   [SO3G, W, M2] = quadratureSO3rid(M, 'ClenshawCurtis') quadrature grid of type Clenshaw Curtis
%


% persistent SO3G_p;
% persistent W_p;
% persistent M2_p;

if check_option(varargin, 'gauss') || check_option(varargin, 'chebyshev')
  warning('Quadrature of types gauss and chebychev are not implemented yet.')
  return
end


% if check_option(varargin, 'ClenshawCurtis')
%   M2 = bandwidth;                           % bandwidth
%   % grid has to be full sized
%   N =  (2*bandwidth+2)^2*(2*bandwidth+1);   % number of nodes
% end
% 
% if ~isempty(M2_p) && M2_p == M2 && length(SO3G_p) == N
%   SO3G = SO3G_p;
%   if check_option(varargin,'Euler') && isa(SO3G,'rotation')
%     SO3G = Euler(SO3G);
%   elseif ~check_option(varargin,'Euler') && isnumeric(SO3G)
%     [CS,SS] = extractSym(varargin);
%     SO3G = orientation.byEuler(SO3G(:,:,:,1),SO3G(:,:,:,2),SO3G(:,:,:,3),'nfft',CS,SS);
%   end
%   W = W_p;
%   M2 = M2_p;
%   
% else
  if check_option(varargin,'ClenshawCurtis')
    SO3G = regularSO3Grid('ClenshawCurtis','bandwidth',bandwidth,varargin{:});

    w = fclencurt2(bandwidth+1);
    if size(SO3G,2) == 1+bandwidth/2
      w = w(1:size(SO3G,2));
    end
    % W = normalized volume * 2xGauß-quadrature-weights * Clenshaw-Curtis-quadrature-weights 
    % W =     1/sqrt(8*pi^2)    *      (2*pi/(2*N+2))^2     *              w_b^N
    W = 1/(2*size(SO3G,1)*size(SO3G,3))*repmat(w',size(SO3G,1),1,size(SO3G,3));
  end
%   % store the data
%   SO3G_p = SO3G;
%   W_p = W;
%   M2_p = M2;
% end

end

function w = fclencurt2(n)

  c = zeros(n,2);
  c(1:2:n,1) = (2./[1 1-(2:2:n-1).^2 ])';
  c(2,2)=1;
  f = real(ifft([c(1:n,:);c(n-1:-1:2,:)]));
  w = 2*([f(1,1); 2*f(2:n-1,1); f(n,1)])/2;
  %x = 0.5*((b+a)+n*bma*f(1:n1,2));

end


