function T = symmetrise(T)
% symmetrise a tensor according to its crystal symmetry

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

% take the mean 
T.M = nanmean(T.M,T.rank+1);

% NaN values become zero again
T.M(isnan(T.M)) = 0;
