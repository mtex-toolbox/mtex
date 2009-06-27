function [q_mean kappa v q q_std] = mean(S3G,varargin)
% returns mean, kappas and sorted q of crystal symmetry euqal quaternions 
%
%% Input
%  q         - list of @quaternion
%  cs        - crystal @symmetry
%
%% Options
%  weights   - list of weights
%
%% Output
%  mean      - one equivalent mean orientation @quaternion
%  kappa     - parameters of bingham distribution
%  v         - eigenvectors of kappa
%  q_res     - list of @quaternion around mean
%

if length(S3G) == 1 && length(S3G.Grid) == 1
  q_mean = S3G.Grid;
  % !!!!!!!!!!  TODO !!!!!!!!!!!!!!!!!!!!
  if nargout > 1
    v = idquaternion;
    kappa = [1 0 0 0];
    q_std = 0;
  end
  return;
end

% first approximation
q_mean = get_option(varargin,'q0',S3G(1).Grid(1));
old_mean = [];

% iterate mean 
iter = 1;
while iter < 5 && (isempty(old_mean) || (dot(q_mean,old_mean)<0.999))
  iter = iter + 1;
  old_mean = q_mean;  
  [q,omega] = getFundamentalRegion(S3G,old_mean);
  q_std = sum(omega.^2) ./ (length(omega)-1);
  [q_mean kappa v] = mean(q,varargin{:});
end
%kappa = K; %kappa = solve_kappa(K);

%function kappas = solve_kappa(lambda)
%dsolve('hypergeom(1/2,2,k) = Dk*lambda','lambda') ?
