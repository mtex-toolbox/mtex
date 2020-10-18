function [T,p,v] = bingham_test(ori,varargin)
% bingham test for spherical/prolat/oblat case
%
% Input
%  ori      - @orientation
%
% Options
%  spherical - test case
%  prolate    -
%  oblate     - 
%  c_hat     - test without kappas
%
% See also
%  evalkappa c_hat


test_fun = parseArgs(varargin{:});

if strfind(test_fun,'chat')
  [kappa, lambda, ~, n] = c_hat(ori);
else
  [~,~, lambda] = mean(ori,varargin{:});
  kappa = evalkappa(lambda,varargin{:});
  n = length(ori);
end

if isempty(strfind(test_fun,'chat'))
  lambda = sort(lambda,'descend');
  kappa  = sort(kappa,'descend');
else
  if ~issorted(lambda(4:-1:1)),
    warning('assure lambda 1 > lambda 2 .. > lambda 4, as well as corresonding chat');
  end
end

[p,v] = feval(test_fun, n, kappa, lambda);

T = 1-gammainc(p/2,v/2,'upper');
% v=2, exp(-x/2)
% T = 1-chi2cdf(p,v);

end

function [test_fun]= parseArgs(varargin)

if check_option(varargin,{'sphere','spherical'})
  test_fun = 'spher';
elseif check_option(varargin,{'prolate','prolatnes','prolateness'})
  test_fun = 'prolat';
elseif check_option(varargin,{'oblate','oblatnes','oblateness'})
  test_fun = 'oblat';
end

  test_fun = ['test_' test_fun];

if check_option(varargin,{'hat','chat','c_hat'})
  test_fun = [test_fun '_chat'];
end
end

%-- spherical ------------------------------------------------------------%
function [p,chin]= test_spher(n,kappa,lambda)
  mkappas = mean(kappa(2:4,:));
  mlambdas = mean(lambda(2:4,:));

  slam = @(i) (kappa(i,:)-mkappas).*(lambda(i,:)-mlambdas);
  p = n.*(slam(2)+slam(3)+slam(4));
  
  chin = 5; % freedom
end

function [p,chin] = test_spher_chat(n,chat,lambda)
  p = 15*n * ...
    ( sum(lambda(2:4).^2) - (1-lambda(1))^2/3 ) / ...
    (  2*( 1- 2*lambda(1) + chat(1,1)));
  chin = 5;
end
  
%-- prolatnes ------------------------------------------------------------%
function [p,chin] = test_prolat(n,kappa,lambda)
  
  p = n/2.*(kappa(3,:)-kappa(4,:)).*(lambda(3,:)-lambda(4,:));
  kappa = sort(kappa,'descend'); 
  chin = 2; % freedom
end
function [p,chin] = test_prolat_chat(n,chat,lambda)
  p = 8*n .* ...
    ( sum(lambda(3:4).^2) - (1-lambda(1)-lambda(2))^2/2 ) / ...
    (  2*( 1- 2*sum(lambda(1:2)) + chat(1,1) + 2*chat(1,2) + chat(2,2)));
  chin = 2; % freedom
end

%-- oblatnes -------------------------------------------------------------%
function [p,chin] = test_oblat(n,kappa,lambda)
  p = n/2.*(kappa(2,:)-kappa(3,:)).*(lambda(2,:)-lambda(3,:));

  chin = 2; % freedom
end
function [p,chin] = test_oblat_chat(n,chat,lambda)
  p = 8*n .* ...
    ( sum(lambda(2:3).^2) - (1-lambda(1)-lambda(4))^2/2 ) / ...
    ( 2*( 1- 2*sum(lambda([1,4])) + chat(1,1) + 2*chat(1,4) + chat(4,4)));
  chin = 2; % freedom
    
end