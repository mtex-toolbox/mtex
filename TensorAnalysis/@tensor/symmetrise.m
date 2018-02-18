function T = symmetrise(T)
% symmetrise a tensor according to its crystal symmetry

% for rank 0 and 1 tensors there is nothing to do
if T.rank <= 1, return; end

M_old = T.M;

% make symmetric if neccasarry
% rank 2 and 4  only
if T.rank == 4 || T.rank == 2  
  if T.rank == 4, T.M = tensor42(T.M,T.doubleConvention);end
    
  % if only a tridiagonal matrix is given -> symmetrise
  if all(all(0 == triu(T.M,1))) || all(all(0 == tril(T.M,-1)))
    T.M = triu(T.M) + triu(T.M,1).' + tril(T.M,-1) + tril(T.M,-1).';
  end
  if T.rank == 4, T.M = tensor24(T.M,T.doubleConvention);end
end

% make all missing values imaginary
T.M(T.M==0) = 1i;

% rotate according to symmetry
T = rotate(T,T.CS);

% set all entries that contain missing values to NaN
T.M(~isnull(imag(T.M))) = NaN;
T.M = real(T.M);

% take the mean 
T.M = nanmean(T.M,T.rank+1);

% check whether something has changed 
if any(abs(T.M(:)-M_old(:))./max(abs(M_old(:)))>1e-6 & ~isnull(M_old(:)))
  warning('MTEX:tensor','Tensor does not pose the right symmetry');
end

% NaN values become zero again
T.M(isnan(T.M)) = 0;
