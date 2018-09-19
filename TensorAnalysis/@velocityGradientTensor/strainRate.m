function e = strainRate(L)
% strain rate 

if all(L.isSymmetric(:))
  e = 0.5*max(eig(L));
else

  for n = 1:length(L)
    
    e(n) = 0.5 * svds(L.M(:,:,n),1);

  end

end