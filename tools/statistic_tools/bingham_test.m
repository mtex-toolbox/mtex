function [T,p,v] = binham_test(o,varargin)
% bingham test for spherical/prolat/oblat case
%
%% Input
%  o      - @orientation / @EBSD / @grain
%
%% Options
%  spherical - test case
%  prolat    -
%  oblat     - 
%  c_hat     - test without kappas
%
%% See also
%  evalkappa c_hat


test_fun = parseArgs(varargin{:});

if isa(o,'EBSD')
  o = get(o,'orientations','checkPhase',varargin{:});
  if strfind(test_fun,'chat')
    [kappa lambda Tv n] = c_hat(o);
  else
    [q lambda Tv kappa] = mean(o,varargin{:});
    n = numel(o);  
  end
elseif isa(o,'double')
  n = o;
  kappa = varargin{1};
  lambda = varargin{2};
end

[p,v] = feval(test_fun, n, kappa, lambda);

switch v  % chi2pdf
  case 2
    chi2v = @(x) exp(-x./2)./2;
  case 5
    chi2v = @(x) exp(-x./2).*x.^(3/2)./(3*sqrt(2*pi));
end
  
T = chi2v( p );



function [test_fun]= parseArgs(varargin)

if check_option(varargin,{'sphere','spherical'})
  test_fun = 'spher';
elseif check_option(varargin,{'prolat','prolatnes'})
  test_fun = 'prolat';
elseif check_option(varargin,{'oblat','oblatnes'})
  test_fun = 'oblat';
end

  test_fun = ['test_' test_fun];

if check_option(varargin,{'hat','chat','c_hat'})
  test_fun = [test_fun '_chat'];
end


%-- spherical ------------------------------------------------------------%
function [p,chin]= test_spher(n,kappa,lambda)
  kappa = sort(kappa,'descend');
  lambda = sort(lambda,'descend');
  mkappas = mean(kappa(2:4,:));
  mlambdas = mean(lambda(2:4,:));

  slam = @(i) (kappa(i,:)-mkappas).*(lambda(i,:)-mlambdas);
  p = n.*(slam(2)+slam(3)+slam(4));
  
  chin = 5; % freedom
  
function [p,chin] = test_spher_chat(n,chat,lambda)
	p = 15*n * ...
    ( sum(lambda(2:4).^2) - (1-lambda(1))^2/3 ) / ...
    (  2*( 1- 2*lambda(1) + chat(1,1)));
  chin = 5;

  
%-- prolatnes ------------------------------------------------------------%
function [p,chin] = test_prolat(n,kappa,lambda)  
  kappa = sort(kappa,'descend');
  lambda = sort(lambda,'descend');

  p = n/2.*(kappa(3,:)-kappa(4,:)).*(lambda(3,:)-lambda(4,:));
    kappa = sort(kappa,'descend');
  chin = 2; % freedom
  
function [p,chin] = test_prolat_chat(n,chat,lambda)
	p = 8*n .* ...
    ( sum(lambda(3:4).^2) - (1-lambda(1)-lambda(2))^2/2 ) / ...
    (  2*( 1- 2*sum(lambda(1:2)) + chat(1,1) + 2*chat(1,2) + chat(2,2)));
  chin = 2; % freedom
  

%-- oblatnes -------------------------------------------------------------%
function [p,chin] = test_oblat(n,kappa,lambda)
  kappa = sort(kappa,'descend');
  lambda = sort(lambda,'descend');

  p = n/2.*(kappa(2,:)-kappa(3,:)).*(lambda(2,:)-lambda(3,:));

  chin = 2; % freedom

function [p,chin] = test_oblat_chat(n,chat,lambda)
	p = 8*n .* ...
    ( sum(lambda(2:3).^2) - (1-lambda(1)-lambda(4))^2/2 ) / ...
    ( 2*( 1- 2*sum(lambda([1,4])) + chat(1,1) + 2*chat(1,4) + chat(4,4)));
  chin = 2; % freedom
    