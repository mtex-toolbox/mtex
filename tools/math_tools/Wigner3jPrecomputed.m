function wigner = Wigner3jPrecomputed(l,L,m1,m2)

global w3j;

% look for a stored file
if isempty(w3j)  
  fname = [mtexDataPath '/Wigner3j.mat'];
  if exist(fname,'file'), load(fname,'w3j'); end
end
  
% check whether w3j are already precomputed
if numel(w3j)>=1+l && ~isempty(w3j{1+l})
  wigner = w3j{1+l}(l+1+m1,l+1+m2,L+1);
  return
end

disp(['I''m going to compute the Wigner 3j coefficients for l=' int2str(l)]);

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

% and save it for future use
fname = [mtexDataPath '/Wigner3j.mat'];
save(fname,'w3j','-v7.3')

% return value
wigner = tmp(l+1+m1,l+1+m2,L+1);
