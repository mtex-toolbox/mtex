function check_EinsteinSum
% contraction semantics of EinsteinSum: summation indices between and
% within tensors, output order, and how tensor arrays line up

rng(0)

checkContraction;
checkSelfTrace;
checkArrayAlignment;

disp('check_EinsteinSum: passed');

end

% -------------------------------------------------------------------------
function checkContraction
% C_jl = A_jkl B_lik with the output order set by the indices, not by the
% position of the operands, on dimensions that are not 3

A = tensor(rand(3,5,4),'rank',3,'noCheck');
B = tensor(rand(4,3,5),'rank',3,'noCheck');

ref = zeros(3,3);
for i = 1:3
  for j = 1:3
    for k = 1:5
      for l = 1:4
        ref(i,j) = ref(i,j) + A.M(j,k,l) * B.M(l,i,k);
      end
    end
  end
end

C = EinsteinSum(A,[2 -1 -2],B,[-2 1 -1]);
assert(C.rank == 2 && max(abs(C.M(:) - ref(:))) < 1e-12, ...
  'check_EinsteinSum: contraction over two indices is wrong')

% a plain outer product
v = vector3d.rand; w = vector3d.rand;
assert(max(abs(reshape(EinsteinSum(tensor(v),1,w,2).M,[],1) - ...
  reshape(xyz(v).' * xyz(w),[],1))) < 1e-12, ...
  'check_EinsteinSum: outer product is wrong')

end

% -------------------------------------------------------------------------
function checkSelfTrace
% an index repeated within one tensor sums its diagonal, also interleaved
% and combined with a contraction against another tensor

T = tensor(rand(3,3,3,3),'rank',4,'noCheck');
x = vector3d.rand; xx = xyz(x);

ref = 0; refx = 0;
for k = 1:3
  for l = 1:3
    ref = ref + T.M(k,l,k,l);
    for m = 1:3
      refx = refx + T.M(k,l,m,m) * xx(k) * xx(l);
    end
  end
end

assert(abs(EinsteinSum(T,[-1 -2 -1 -2]) - ref) < 1e-12, ...
  'check_EinsteinSum: interleaved self trace is wrong')
assert(abs(EinsteinSum(T,[-1 -2 -3 -3],x,-1,x,-2) - refx) < 1e-12, ...
  'check_EinsteinSum: self trace combined with a contraction is wrong')

% a rank zero result is a double shaped like the tensor array
t = trace(tensor(rand(3,3,1,5),'rank',2,'noCheck'));
assert(isa(t,'double') && isequal(size(t),[1 5]), ...
  'check_EinsteinSum: rank zero result is not a 1 x 5 double')

end

% -------------------------------------------------------------------------
function checkArrayAlignment
% array dimensions of the operands line up position by position, so an
% N x 1 array against an N x 1 array is elementwise and a 1 x N array
% against an M array gives all M x N combinations

N = 4; M = 3;
T = tensor(rand(3,3,N),'rank',2,'noCheck');
v = vector3d.rand(N,1); xv = xyz(v);
R = matrix(rotation.rand(M,1));

Tv = EinsteinSum(T,[1 -1],v,-1);
assert(isequal(size(Tv.M),[3 N]) && ...
  max(abs(Tv.M(:,2) - T.M(:,:,2) * xv(2,:).')) < 1e-12, ...
  'check_EinsteinSum: elementwise pairing of tensor arrays is wrong')

T1N = reshape(T,1,N);
RT = EinsteinSum(T1N,[-1 2],R,[1 -1]);
assert(isequal(size(RT.M),[3 3 M N]) && ...
  max(abs(reshape(RT.M(:,:,3,2) - R(:,:,3) * T.M(:,:,2),[],1))) < 1e-12, ...
  'check_EinsteinSum: singleton expansion of tensor arrays is wrong')

end
