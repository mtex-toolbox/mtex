function s = sum_K(kk,g1,g2,CS,SS,c,varargin)
% sum up kernels modulo symmetries
%% Syntax
% w = sum_K(kk,g1,g2,CS,SS,c,<options>)
%
%% Input
%  kk     - @kernel
%  g1, g2 - @quaternion(s)
%  CS, SS - crystal , specimen @symmetry
%  c      - double 
%
%% Options
%  EXACT - 
%  EPSILON - 
%
%% general formula:
% s(g1_i) = sum_j c_j K(g1_i,g2_j) 


% how to index grid representation 
if isa(g1,'SO3Grid') && check_option(g1,'indexed'),
  lg1 = GridLength(g1);
else
  lg1 = -numel(quaternion(g1));
end
if isa(g2,'SO3Grid') && check_option(g2,'indexed')
  lg2 = GridLength(g2);
else
  lg2 = -numel(quaternion(g2));
end

% check sparsity of the kernel matrix
if (lg1 > lg2 && lg1 > 0) || (abs(lg1) > abs(lg2) && lg2 < 0)
  g2 = quaternion(g2); 
  total_nnz = numel(g2) * nnz(K(kk,g1,g2(1),CS,SS,varargin));
else
  g1 = quaternion(g1);
  total_nnz = numel(g1) * max(1,nnz(K(kk,g1(1),g2,CS,SS,varargin)));
end

% init variables
global mtex_memory;
s = zeros(size(quaternion(g1)));

% iterate due to memory restrictions?
maxiter = ceil(total_nnz / mtex_memory);
if maxiter > 1, progress(0,maxiter);end

for iter = 1:maxiter
   
  if maxiter > 1, progress(iter,maxiter); end
   
  if (lg1 > lg2 && lg1 > 0) || (abs(lg1) > abs(lg2) && lg2 < 0) 
    % split along g2
    
    dind = ceil(numel(g2) / maxiter);
    ind = 1+(iter-1)*dind:min(numel(g2),iter*dind);
      
    M = K(kk,g1,g2(ind),CS,SS,varargin{:},'nocubictrifoldaxis');
    s = s + reshape(M * reshape(c(ind),[],1),size(s));
      
  else % split along g1
    
    dind = ceil(numel(g1) / maxiter);
    ind = 1+(iter-1)*dind:min(numel(g1),iter*dind);
      
    M = K(kk,g1(ind),g2,CS,SS,varargin{:},'nocubictrifoldaxis');
    s(ind) = s(ind) + reshape(M * c(:),size(s(ind)));
      
  end
end

