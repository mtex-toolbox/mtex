function [m kappa v q_res] = mean(S3G,varargin)
% returns mean, kappas and sorted q of crystal symmetry euqal quaternions 
%
%% Input
%  q         - list of @quaternion
%  cs        - crystal @symmetry
%  varargin  - list of weights
%
%% Output
%  mean      - one equivalent mean orientation @quaternion
%  kappa     - parameters of bingham distribution
%  v         - eigenvectors of kappa
%  q_res     - list of @quaternion around mean
%

q = quaternion(S3G);

if ~isempty(varargin)
    w = reshape(varargin{1},1,[]);
else
    w = ones(GridSize(S3G));
end

m = q(1);
old_mean = inverse(q(1));
q_cs = quaternion(getCSym(S3G));

while (m ~= old_mean) 
    old_mean = m;
    q_res = rearrange(m,q,q_cs);
    [m kappa v] = mean(q_res,w);
end
%kappa = K; %kappa = solve_kappa(K);



function q_res = rearrange(q_ref,q,q_cs)
% arrange equivalent q_cs*q arround q_ref

q_ref = inverse(q_ref);

q_cceq = q_cs * q;
sc = rotangle(q_cceq*q_ref);
ind = sc == repmat(min(sc,[],1),length(q_cs),1);
ind = ind & ind == cumsum(ind,1);
q_res = q_cceq(ind);


%function kappas = solve_kappa(lambda)
%dsolve('hypergeom(1/2,2,k) = Dk*lambda','lambda') ?

