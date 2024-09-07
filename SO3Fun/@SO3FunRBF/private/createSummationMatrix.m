function M = createSummationMatrix(psi,S3G,ori,varargin)
% creates system matrix Psi, length(S3G) x length(ori) to solve a system of
% linear equations Psi*c = I, where c are the weights for the kernels psi
% and I is the intensity to fit.

% this check is also present in psi.K_symmetrised
if check_option(varargin,'exact') 
  epsilon = pi; 
else
  epsilon = min(pi,get_option(varargin,'epsilon',psi.halfwidth*3.5)); 
end

if epsilon>2*pi/ori.CS.Laue.multiplicityZ % compute full matrix
  M = psi.K_symmetrised(S3G,ori,ori.CS,ori.SS,varargin{:});
  return
end

% decide along which dimension to split the summation matrix
if isa(S3G,'SO3Grid')
  lg1 = length(S3G); 
else
  lg1 = -length(S3G);
end
if isa(ori,'SO3Grid')
  lg2 = length(ori);
else
  lg2 = -length(ori);
end

along = (lg1 > lg2 && lg1 > 0) || (abs(lg1) > abs(lg2) && lg2 < 0);
if along
  num = abs(lg2);
else
  num = abs(lg1);
end

% init variables
iter = 0; numiter = 1; ind = 1; %for first run
M = sparse(abs(lg1),abs(lg2));

% now iterate along the splitting
while iter <= numiter
  if iter > 0% split
    ind = 1 + (1+(iter-1)*diter:min(num-1,iter*diter));
    if isempty(ind), return; end
  end

  %eval the kernel
  if along
    m = psi.K_symmetrised(S3G,ori(ind),ori.CS,ori.SS,varargin{:});
    M(:,ind) = M(:,ind) + m;
  else
    m = psi.K_symmetrised(S3G(ind),ori,ori.CS,ori.SS,varargin{:});
    M(ind,:) = M(ind,:) + m;
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

end