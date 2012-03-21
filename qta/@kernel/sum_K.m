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
%
% $$s(g1_i) = sum_j c_j K(g1_i,g2_j) $$


% how to index grid representation 
if isa(g1,'SO3Grid') && check_option(g1,'indexed'),
  lg1 = numel(g1);
else
  lg1 = -numel(g1);
end
if isa(g2,'SO3Grid') && check_option(g2,'indexed')
  lg2 = numel(g2);
else
  lg2 = -numel(g2);
end

along = (lg1 > lg2 && lg1 > 0) || (abs(lg1) > abs(lg2) && lg2 < 0);
if along
  g2 = quaternion(g2);
  num = numel(g2);
else
  g1 = quaternion(g1);
  num = numel(g1);
end  
    
% init variables
s = zeros(size(quaternion(g1)));
iter = 0; numiter = 1; ind = 1; %for first run

while iter <= numiter  
  if iter > 0,% split
    ind = 1 + (1+(iter-1)*diter:min(num-1,iter*diter));
    if isempty(ind), return; end
  end
  
  %eval the kernel
  if along 
    M = K(kk,g1,g2(ind),CS,SS,'nocubictrifoldaxis',varargin{:});
    s = s + reshape(full(M * reshape(c(ind),[],1)),size(s));  
  else    
    M = K(kk,g1(ind),g2,CS,SS,'nocubictrifoldaxis',varargin{:});
    s(ind) = s(ind) + reshape(full(M * c(:)),size(s(ind)));
  end 
  
  if num == 1
    return  
  elseif iter == 0, % iterate due to memory restrictions?    
    numiter = ceil( max(1,nnz(M))*num / get_mtex_option('memory',300 * 1024) );
    diter = ceil(num / numiter);
  end
  
  if numiter > 1 && ~check_option(varargin,'silent'), progress(iter,numiter); end
  
  iter = iter + 1;
end
