function C = mtimesxx(A,B)


[szA(1),szA(2),szA(3),szA(4)] = size(A);
[szB(1),szB(2),szB(3),szB(4)] = size(B);
sz = max(szA,szB);

if ndims(B) < 3 || ndims(A) < 3
  A = reshape(reshape(A,szA(1)*szA(2),[])',[],szA(2));
  B = reshape(reshape(B,szB(1)*szB(2),[])',szB(1),[]);
  C = A*B;
  C = reshape(reshape(C,[],szA(1)*szB(2))',szA(1),szB(2),sz(3),sz(4));
else
  C = zeros(szA(1),szB(2),sz(3),sz(4));
  for l=1:sz(4)
    for k=1:sz(3)
      C(:,:,k,l) = A(:,:,k,l)*B(:,:,k,l);
    end
  end
end
