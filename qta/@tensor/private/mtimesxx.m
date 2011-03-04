function C = mtimesxx(A,B)

for k=1:4
  szA(k) = size(A,k);
  szB(k) = size(B,k);
end

sz = max(szA,szB);

C = zeros(szA(1),szB(2),sz(3),sz(4));

for k=1:sz(3)
  for l=1:sz(4)
    C(:,:,k,l) = A(:,:, min(k,szA(3)), min(l,szA(4)))*B(:,:, min(k,szB(3)), min(l,szB(4)));
  end
end