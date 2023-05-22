function SO3F = L2normalizeFourierCoefficients(SO3F)
% Since MTEX version 5.9 we use L2 normalized Wigner-D functions as basis
% functions for the harmonic series expansion of ODFs/SO3Funs.
%
% Up to MTEX version 5.8 the ODFs has been definded by
%         $$ F({\bf R}) = \sum \hat{f}_n^{k,l} \, D_n^{k,l}({\bf R})$$
% with $ D_n^{k,l}({\bf R}(\alpha,\beta,\gamma)) = \mathrm e^{-\mathrm i k\gamma} \mathrm
% d_n^{k,l}(\cos\beta) \,e^{-\mathrm i l\alpha} $. Hence the $L_2$ norm of
% the Wigner-D function $D_n^{k,l}$ was $\sqrt{2n+1}$.
% 
% Now since MTEX version 5.9 the Wigner-D functions have $L_2$ norm 1.
% Hence they are defined by $ D_n^{k,l}({\bf R}(\alpha,\beta,\gamma)) = 
% \sqrt{2n+1} \, \mathrm e^{-\mathrm i k\gamma} \mathrm d_n^{k,l}(\cos\beta) \, 
% e^{-\mathrm i l\alpha} $.
%
% Take a look at <WignerFunctions.html Wigner-D functions>.
%

fhat = SO3F.fhat;
for n = 0:SO3F.bandwidth
  ind = deg2dim(n)+1:deg2dim(n+1);
  fhat(ind) = fhat(ind) /sqrt(2*n+1);
end
SO3F.fhat = fhat;

end