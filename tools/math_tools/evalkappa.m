function kappa = evalkappa(lambda,varargin)
% eigenvalues of orientation tensor to bingham distribution parameters
%
% Options
%  approximated - approximated solution of kappas
%  precision    - precision of solvus
%  iteration    - number of newton interations
%
% See also
% orientation/mean EBSD/mean BinghamODF

if check_option(varargin,'approximated')
  kappa = evalkappaapprox(lambda);
else
  d = int32(get_option(varargin,{'prec','precision'},64,'double'));
  iter = int32(get_option(varargin,{'iter','iterations'},5,'double'));

  if sum(lambda) ~= 1,
    lambda(4) = 1-sum(lambda(1:3));
    % warning('sum of lambdas should be exactly 1')
  end
  
  try
    kappa = call_extern('evalmhyper','intern',d,iter,'EXTERN',lambda);
  catch
    %warning('only approximated solution of kappas')
    kappa = evalkappaapprox(lambda);
  end
end

function kappa = evalkappaapprox(lambda)

lambda = sort(lambda);
kappa = -1./(2.*lambda);
kappa(4) = 0;
kappa = kappa - kappa(1);

% kappa = sort(1./((2.*lambda-1).*lambda));
% kappa = (kappa-min(kappa))/2;
