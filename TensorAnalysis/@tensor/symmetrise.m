function T = symmetrise(T,cs)
% symmetrise a tensor according to its crystal symmetry
%
% Syntax
%   % symmetrise according to a crystal symmetry
%   T = symmetrise(T,cs)
%
%   % symmetrise transversally allong direction d
%   T = symmetrise(T,d)
%
% Input
%
%  T  - @tensor
%  cs - @symmetry
%  d  - @vector3d
%
% Output
%  T  - @tensor
%

% extract symmetry
if nargin == 1, cs = T.CS; end
  
% symmetrise transversally
if isa(cs,'vector3d')

  omega = linspace(0,360,3610) * degree;
  
  % all rotations 0 to 360
  rot = rotation.byAxisAngle(cs,omega);
  
  % average over all rotations
  T = reshape(mean(rot * T),size(T));
  
  return
end

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
T = rotate(T,cs.rot);

% set all entries that contain missing values to NaN
T.M(~isnull(imag(T.M))) = NaN;
T.M = real(T.M);

% take the mean 
T.M = nanmean(T.M,T.rank+1);

% check whether something has changed 
if any(abs(T.M(:)-M_old(:))./max(abs(M_old(:)))>1e-4 & ~isnull(M_old(:)))
  warning('MTEX:tensor',[T.CS.mineral ' Tensor does not pose the right symmetry']);
  disp(['Deviation:' xnum2str(nanmax(abs(T.M(:)-M_old(:))))]);
end

% NaN values become zero again
T.M(isnan(T.M)) = 0;
