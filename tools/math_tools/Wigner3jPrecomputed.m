function wigner = Wigner3jPrecomputed(l,L,m1,m2)

global w3j;

% check whether w3j are already precomputed
try
  wigner = w3j{1+l}(l+1+m1,l+1+m2,L+1);
  return
catch %#ok<CTCH>
  disp(['I''m going to compute the Wigner 3j coefficients for l=' int2str(l)]);
end

% precompute w3j{l} -> (m1 x m2 x L)
tmp = zeros(2*l+1,2*l+1,2*l);

for mm1 = -l:l
  for mm2 = -l:l
    [x,jmin,jmax] = Wigner3j_new(l,l,-mm1-mm2,mm1,mm2);
    tmp(l+1+mm1,l+1+mm2,1+(jmin:jmax)) = x;
    
  end
end

% store in global variable
w3j{l+1} = tmp;

% return value
wigner = tmp(l+1+m1,l+1+m2,L+1);
