function f = eval(component,g,varargin)
% evaluate sum of unimodal components at orientation g
%
% Syntax
%   w = eval(component,g)
%
% Input
%  component - @unimodalComponent
%  g - @orientation
%
% Options
%  exact -
%  EPSILON -
%
% Description
% general formula:
%
% $$s(g1_i) = sum_j c_j K(g1_i,g2_j) $$

% decide along which dimension to split the summation matrix
if isa(g,'SO3Grid')
  lg1 = length(g);
else
  lg1 = -length(g);
end
if isa(component.center,'SO3Grid')
  lg2 = length(component.center);
else
  lg2 = -length(component.center);
end

along = (lg1 > lg2 && lg1 > 0) || (abs(lg1) > abs(lg2) && lg2 < 0);
if along
  num = abs(lg2);
else
  num = abs(lg1);
end

% init variables
f = zeros(size(g));
iter = 0; numiter = 1; ind = 1; %for first run

% now iterate along the splitting
while iter <= numiter
  if iter > 0% split
    ind = 1 + (1+(iter-1)*diter:min(num-1,iter*diter));
    if isempty(ind), return; end
  end

  %eval the kernel
  if along
    M = component.psi.K_symmetrised(g,component.center(ind),component.CS,component.SS,'nocubictrifoldaxis',varargin{:});
    if component.antipodal
      M = 0.5*(M + component.psi.K_symmetrised(g,inv(component.center(ind)),component.CS,component.SS,'nocubictrifoldaxis',varargin{:}));
    end
    f = f + reshape(full(M) * reshape(component.weights(ind),[],1),size(f));
  else
    M = component.psi.K_symmetrised(g(ind),component.center,component.CS,component.SS,'nocubictrifoldaxis',varargin{:});
    if component.antipodal
      M = 0.5*(M + component.psi.K_symmetrised(inv(g(ind)),component.center,component.CS,component.SS,'nocubictrifoldaxis',varargin{:}));
    end
    f(ind) = f(ind) + reshape(full(M) * component.weights(:),size(f(ind)));
  end

  if num == 1
    return
  elseif iter == 0 % iterate due to memory restrictions?
    numiter = ceil( max(1,nnz(M))*num / getMTEXpref('memory',300 * 1024) );
    diter = ceil(num / numiter);
  end

  if numiter > 1 && ~check_option(varargin,'silent'), progress(iter,numiter); end

  iter = iter + 1;
end

end

