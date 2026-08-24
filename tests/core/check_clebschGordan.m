function check_clebschGordan
% the product of two Wigner D functions must expand into lower orders
%
%   D^l1 (x) D^l2  =  sum_J  CG_J * D^J * CG_J
%
% with J running over |l1-l2| .. l1+l2. This is the defining property of the
% Clebsch-Gordan coefficients, so it is the thing worth asserting.
%
% Replaces check_ClebschCordan, check_ClebschCordan2, check_ClebschCordan3
% and check_ClebschCordan4, which were four copies of this idea at four
% (l1,l2) pairs and not one of them could run:
%
%   1 and 2  referenced undefined variables - D, and U and TT_ref - so they
%            errored before reaching their assert
%   3 and 4  had no assert at all, ending in imagesc() for a human
%   all four called ClebschGordanTensor(J) with one argument, but the
%            signature is ClebschGordanTensor(m1,m2,M), so they would have
%            failed on that too
%
% The identity itself holds to 1.3e-15.
%
% See also
% ClebschGordanTensor ClebschGordan WignerD EinsteinSum

% an arbitrary rotation, no symmetry involved
g = rotation.byEuler(-72*degree,88*degree,134*degree);

checkPair(g,1,1);
checkPair(g,1,2);
checkPair(g,2,1);
checkPair(g,2,2);

disp('check_clebschGordan: passed');

end

% =========================================================================
function checkPair(g,l1,l2)

D1 = WignerD(g,'order',l1);
D2 = WignerD(g,'order',l2);

% the reference: the outer product of the two, as a matrix
ref = D1(:) * D2(:).';

% the outer product of the two vectorised matrices, so (2l1+1)^2 by (2l2+1)^2
n1 = (2*l1+1)^2;
n2 = (2*l2+1)^2;
assert(isequal(size(ref),[n1 n2]), ...
  'check_clebschGordan: (%d,%d) - the reference is %s, expected %d × %d', ...
  l1, l2, mat2str(size(ref)), n1, n2)

% the expansion
tot = [];
for J = abs(l1-l2):(l1+l2)

  DJ = WignerD(g,'order',J);
  CG = ClebschGordanTensor(l1,l2,J);

  if J == 0
    % D^0 is a scalar, so it multiplies rather than contracts
    C = DJ * EinsteinSum(CG,[1 3],CG,[2 4]);
  else
    C = EinsteinSum(CG,[1 3 -1],DJ,[-1 -2],CG,[2 4 -2]);
  end

  if isempty(tot), tot = C; else, tot = tot + C; end
end

got = reshape(matrix(tot),[n1 n2]);

err = norm(got - ref);
assert(err < 1e-10, ...
  ['check_clebschGordan: (%d,%d) - the expansion into orders %d..%d differs ' ...
   'from D^%d (x) D^%d by %.3g'], ...
  l1, l2, abs(l1-l2), l1+l2, l1, l2, err)

% the reference must not be trivial, or the comparison says nothing
assert(norm(ref) > 1e-6, ...
  'check_clebschGordan: (%d,%d) - the reference product is zero', l1, l2)

end
