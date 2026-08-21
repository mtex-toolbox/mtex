function check_tensorFactories
% check the static factories of the rank 4 tensor classes and the arguments
% the tensor constructor accepts
%
% MATLAB gives a static method no way to learn which subclass it was called
% on, so stiffnessTensor.rand resolved to tensor.rand and returned a plain
% rank 2 tensor. Every stiffnessTensor method was then missing - the old
% TensorVisualisation.m used exactly this and was silently plotting a
% random rank 2 tensor while claiming to show a rank 4 one.
%
% Note there are deliberately no zeros, ones or nan counterparts: a
% stiffness tensor has to be symmetric and positive definite, which none of
% those is, and both classes check that on construction. A random one
% therefore cannot be drawn entry by entry either, which is why rand builds
% a Gram matrix instead.

checkClassAndRank;
checkValid;
checkQuiet;
checkShape;
checkSymmetryArgument;
checkNoInvalidFactories;
checkPlottingConvention;

disp('check_tensorFactories: passed');

end

% =========================================================================
function checkClassAndRank

for cls = {'stiffnessTensor','complianceTensor'}
  for f = {'rand','eye'}

    T = feval([cls{1} '.' f{1}]);

    assert(isa(T,cls{1}), ...
      'check_tensorFactories: %s.%s returned a %s', cls{1}, f{1}, class(T))

    assert(T.rank == 4, ...
      'check_tensorFactories: %s.%s has rank %d instead of 4', cls{1}, f{1}, T.rank)

  end
end

end

% -------------------------------------------------------------------------
function checkValid
% what rand returns has to satisfy the invariant the class checks

for cls = {'stiffnessTensor','complianceTensor'}

  rng(0)
  T = feval([cls{1} '.rand']);

  assert(T.isSymmetric, ...
    'check_tensorFactories: %s.rand is not symmetric', cls{1})

  assert(all(eig(T) > 0), ...
    'check_tensorFactories: %s.rand is not positive definite', cls{1})

end

end

% -------------------------------------------------------------------------
function checkQuiet
% and therefore must not trip the constructor's own warnings

for cls = {'stiffnessTensor','complianceTensor'}

  lastwarn('');
  feval([cls{1} '.rand']);
  [msg,~] = lastwarn;

  assert(isempty(msg), ...
    'check_tensorFactories: %s.rand warns "%s"', cls{1}, msg)

end

end

% -------------------------------------------------------------------------
function checkShape
% the array syntax of tensor.rand carries over

C = stiffnessTensor.rand(4);
assert(isequal(size(C),[4 1]), ...
  'check_tensorFactories: stiffnessTensor.rand(4) has size %s', mat2str(size(C)))

C = stiffnessTensor.rand(2,3);
assert(isequal(size(C),[2 3]), ...
  'check_tensorFactories: stiffnessTensor.rand(2,3) has size %s', mat2str(size(C)))

% every entry is its own random tensor, not the same one repeated
C = stiffnessTensor.rand(2);
assert(norm(C(1) - C(2)) > 1e-6, ...
  'check_tensorFactories: stiffnessTensor.rand(2) repeated one tensor')

end

% -------------------------------------------------------------------------
function checkSymmetryArgument

cs = crystalSymmetry('m-3m');
C = stiffnessTensor.rand(cs);

assert(C.CS == cs, ...
  'check_tensorFactories: stiffnessTensor.rand(cs) dropped the symmetry')

% a subclass method has to be callable on the result - this is the point of
% the whole exercise
E = C.YoungsModulus(vector3d.X);
assert(isscalar(E) && isfinite(E), ...
  'check_tensorFactories: YoungsModulus on stiffnessTensor.rand gave %s', mat2str(E))

end

% -------------------------------------------------------------------------
function checkNoInvalidFactories
% zeros, ones and nan are not offered - if someone adds them, they have to
% think about the class invariant first, so this test is the reminder

for f = {'zeros','ones','nan'}

  T = feval(['stiffnessTensor.' f{1}]);

  assert(strcmp(class(T),'tensor'), ...
    ['check_tensorFactories: stiffnessTensor.%s now returns a %s - if that ' ...
    'is intended, it has to be symmetric and positive definite, see ' ...
    '@stiffnessTensor/rand.m'], f{1}, class(T))

end

end

% -------------------------------------------------------------------------
function checkPlottingConvention
% a plottingConvention may be passed positionally, next to a symmetry and
% named options, and survives the copy constructor
%
% it used to land in dynOption/setOption as a name with no value and error.
% That the convention then stays local to this tensor is the subject of
% core/check_plottingConventionOwnership, not of this file.

M = diag([3 1 -1]);
pC = plottingConvention('y↑→x');

% compare conventions as objects, every one that is not axis aligned prints 'xyz'
before = tensor(M,'rank',2).how2plot;
assert(before ~= pC, ...
  ['check_tensorFactories: the test convention equals the default one, so ' ...
  'it cannot detect a leak - pick another one'])

% positionally, on its own and next to a symmetry and a named option
T = tensor(M,'rank',2,pC);
assert(T.how2plot == pC, ...
  'check_tensorFactories: tensor(M,''rank'',2,pC) has convention %s', ...
  char(T.how2plot))

% mmm derives y↑→x from its axes, so pick one differing from it and from the default
cs = crystalSymmetry('mmm');
pCs = plottingConvention('z↑→x');
assert(cs.how2plot ~= pCs && before ~= pCs, ...
  ['check_tensorFactories: the second test convention collides with the ' ...
  'crystal or the specimen default - pick another one'])

T = tensor(M,'rank',2,cs,pCs,'name','foo');
assert(T.how2plot == pCs && strcmp(T.opt.name,'foo'), ...
  'check_tensorFactories: convention, symmetry and name do not survive together')

% the symmetry is neither copied nor written to, other users share that handle
assert(T.CS == cs, ...
  'check_tensorFactories: tensor(M,...,cs,pC) no longer holds cs itself')

assert(cs.how2plot ~= pCs, ...
  'check_tensorFactories: the convention was written onto the caller''s cs')

% and through the copy constructor
assert(tensor(T).how2plot == pCs, ...
  'check_tensorFactories: the copy constructor dropped the convention')

end
