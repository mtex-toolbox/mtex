function hkl = allHKL(maxIndex)
% generate all relevant hkl up to a maximum index modulo

% all combinations
[h,k,l] =meshgrid(0:maxIndex,-maxIndex:maxIndex,-maxIndex:maxIndex);


% ensure first nonzero index is positiv
ind = h>0 | (h==0 & k>0) | (h==0 & k==0 & l>0);

hkl = [h(ind) k(ind) l(ind)];

% ensure there is no common divisor
ind = true(size(hkl,1),1);
for alpha = 2:maxIndex, ind = ind & any(rem(hkl,alpha),2); end

hkl = hkl(ind,:);

end