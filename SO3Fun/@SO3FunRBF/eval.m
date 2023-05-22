function f = eval(SO3F,g,varargin)
% evaluate sum of unimodal components at orientation g
%
% Syntax
%   f = SO3F.eval(g)
%
% Input
%  SO3F - @SO3FunUnimodal
%  rot  - @rotation
%
% Options
%  exact   -
%  epsilon -
%
% Description
% general formula:
%
% $$ f(r) = sum_j w_j \psi(r,c_j) $$

% if isa(g,'orientation')
%   ensureCompatibleSymmetries(SO3F,g)
% end

% decide along which dimension to split the summation matrix
if isa(g,'SO3Grid')
  lg1 = length(g);
else
  lg1 = -length(g);
end

if isa(SO3F.center,'SO3Grid')
  lg2 = length(SO3F.center);
else
  lg2 = -length(SO3F.center);
end

along = (lg1 > lg2 && lg1 > 0) || (abs(lg1) > abs(lg2) && lg2 < 0);
if along
  num = abs(lg2);
else
  num = abs(lg1);
end

% init variables
f = SO3F.c0 * ones(size(g));
iter = 0; numiter = 1; ind = 1; %for first run

% now iterate along the splitting
while iter <= numiter
  if iter > 0% split
    ind = 1 + (1+(iter-1)*diter:min(num-1,iter*diter));
    if isempty(ind), return; end
  end

  %eval the kernel
  if along
    M = SO3F.psi.K_symmetrised(g,SO3F.center(ind),SO3F.CS,SO3F.SS,'nocubictrifoldaxis',varargin{:});
    if SO3F.antipodal
      M = 0.5*(M + SO3F.psi.K_symmetrised(g,inv(SO3F.center(ind)),SO3F.CS,SO3F.SS,'nocubictrifoldaxis',varargin{:}));
    end
    f = f + reshape(full(M * reshape(SO3F.weights(ind),[],1)),size(f));
  else
    M = SO3F.psi.K_symmetrised(g(ind),SO3F.center,SO3F.CS,SO3F.SS,'nocubictrifoldaxis',varargin{:});
    if SO3F.antipodal
      M = 0.5*(M + SO3F.psi.K_symmetrised(inv(g(ind)),SO3F.center,SO3F.CS,SO3F.SS,'nocubictrifoldaxis',varargin{:}));
    end
    f(ind) = f(ind) + reshape(full(M * SO3F.weights(:)),size(f(ind)));
  end

  if num == 1
    return
  elseif iter == 0 % iterate due to memory restrictions?
    numiter = ceil( max(1,nnz(M))*num / getMTEXpref('memory',512 * 1024) / 256 );
    diter = ceil(num / numiter);
  end

  if numiter > 1 && ~check_option(varargin,'silent'), progress(iter,numiter); end

  iter = iter + 1;
end

if isalmostreal(f)
  f = real(f);
end


end
