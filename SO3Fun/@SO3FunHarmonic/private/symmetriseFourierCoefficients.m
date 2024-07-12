function ghat = symmetriseFourierCoefficients(ghat,input_flags,CS,SS,sym)
% The wignerTrafomex function just computes
% $$\hat{h}_{k,j,l} = \sum_{n = \max \{|k|,|j|,|l|\} }^N \sqrt{2n+1}\, \hat{f}_n^{k,l} \, d_n^{j,k}(0) \, d_n^{j,l}(0)$$
% from the harmonic coefficients $\hat{f}_n^{k,l}$
% and only for one of the (up to a sign) symmetric coefficients $\hat{h}_{k,j,l}$.
%
% Now we get the Fourier coefficients by 
% $$\hat{g}_{k,j,l} = i^{k-l} \,\hat{h}_{k,j,l},$$
% since the Wigner transform which computes the Fourier coefficients $\hat{g}_{k,j,l}$ reads as
% $$\hat{g}_{k,j,l} = i^{k-l} \, \sum_{n = \max \{|k|,|j|,|l|\} }^N \sqrt{2n+1}\, \hat{f}_n^{k,l} \, d_n^{j,k}(0) \, d_n^{j,l}(0).$$
%
% Moreover we have to use the symmetry properties
%  * default symmetry property of Wigner-d functions $ghat_{k,j,l} = (-1)^{k+l} \, ghat_{k,-j,l}$
%  * if the function is real valued (flag 2^3)
%  * if there are left or right symmetries (flag 2^4)
% to reconstruct the symmetric Fourier coefficients.

% Compute bandwidth
N = floor((size(ghat,1)-1)/2);

% extract flags:
%        1 -> use L_2-normalized Wigner-D functions
%        2 -> make size of result even
%        3 -> fhat are the Fourier coefficients of a real valued function
%        5 -> use right and left symmetry
flags=zeros(1,6);
while input_flags>0
  a = floor(log2(input_flags));
  flags(a+1)=1;
  input_flags = input_flags-2^a;
end

% compute shift along 3rd dimension depending on whether the function is real-valued
if ~flags(3)
  shift = flags(2);
else
  shift = flags(2)*mod(N+1,2);
end
if flags(3)
  ghat(:,:,1+shift) = ghat(:,:,1+shift)/2;
end

% get Fourier coefficients ghat{k,j,l} = i^{k-l} * hhat(k,j,l)
ind = (1i).^((-N:N)'-reshape(-N*(1-flags(3)):N,1,1,[]));
ghat(1+flags(2):end,flags(2)+(N+1):end,1+shift:end) = ind.*ghat(1+flags(2):end,flags(2)+(N+1):end,1+shift:end);

% Default symmetry property of Wigner-d functions
%     ghat(k,j,l) = (-1)^(k+l) * ghat(k,-j,l)
ind = (-1).^((-N:N)'+reshape(-N*(1-flags(3)):N,1,1,[]));
ghat(1+flags(2):end,(1:N)+flags(2),1+shift:end) = ind.*flip(ghat(1+flags(2):end,flags(2)+(N+2):end,1+shift:end),2);

if ~flags(5)
  return;
end

% An 2-fold rotation around Y-axis in right symmetry yields
%     ghat(k,j,l) = (-1)^(j) * ghat(-k,j,l)
% Note that in case of '211', '321', '312' this property changes slightly
if sym(1)==2
  if ismember(CS.id,3:5) || (ismember(CS.id,22:24) && isa(CS,'crystalSymmetry')) || (ismember(CS.id,19:21) &&(isa(CS,'specimenSymmetry')))
    ind = (-1).^((-N:N)+(-N:-1)');
  elseif ismember(CS.id,22:24) && isa(CS,'specimenSymmetry')
    ind = (-1).^(-N:N).*1i.^(-N:-1)';
  else
    ind = (-1).^(-N:N);
  end
  ghat((1:N)+flags(2),1+flags(2):end,1+shift:end) = ind .* flip(ghat(flags(2)+(N+2):end,1+flags(2):end,1+shift:end),1) ;
end

% An 2-fold rotation around Y-axis in left symmetry yields
%     ghat(k,j,l) = (-1)^(j) * ghat(k,j,-l)
% in case of an real valued function this reads as
%     ghat(k,j,l) = (-1)^(k+j) * ghat(-k,j,l)
% Note that in case of '211', '321', '312' this properties change slightly
if sym(3)==2 && ~flags(3)
  if ismember(SS.id,3:5) || (ismember(SS.id,22:24) && isa(SS,'crystalSymmetry')) || (ismember(SS.id,19:21) && isa(SS,'specimenSymmetry'))
    ind = (-1).^((-N:N)+reshape(-N:-1,1,1,[]));
  elseif (ismember(SS.id,22:24) && isa(SS,'specimenSymmetry'))
    ind = (-1).^(-N:N).*(1i).^(reshape(-N:-1,1,1,[]));
  else
    ind = (-1).^(-N:N);
  end
  ghat(1+flags(2):end,1+flags(2):end,(1:N)+flags(2)) = ind .* flip(ghat(1+flags(2):end,1+flags(2):end,flags(2)+(N+2):end),3) ;
elseif sym(3)==2 && flags(3) && sym(1)~=2
  if ismember(SS.id,6:9) ||  (ismember(SS.id,19:21) && isa(SS,'crystalSymmetry'))
    ind = (-1).^((-N:N)+(-N:-1)'+reshape(0:N,1,1,[]));
  elseif ismember(SS.id,22:24) && isa(SS,'specimenSymmetry')
    ind = (-1).^((-N:-1)'+(-N:N)).*(1i).^(-reshape(0:N,1,1,[]));
  else
    ind = (-1).^((-N:N)+(-N:-1)');
  end
  ghat((1:N)+flags(2),1+flags(2):end,1+shift:end) = ind .* conj(flip(ghat(flags(2)+(N+2):end,1+flags(2):end,1+shift:end),1)) ;
end
return


end