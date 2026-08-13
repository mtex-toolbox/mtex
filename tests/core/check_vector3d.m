function check_vector3d
% checks on the vector3d constructor's shape contract
%
% There was no owner for vector3d construction at all, although it is the
% class the whole geometry chain is built on. This file is it.
%
% The contract, as decided on #2145: a matrix of coordinates keeps the row /
% column correspondence of the three argument form. A 3 x N matrix holds one
% vector per column and gives a 1 x N list; an N x 3 matrix holds one per row
% and gives an N x 1 list, which is what vector3d.byXYZ has always done.
% Previously anything that was not already 3 x N was transposed into it, so
% an N x 3 matrix came back as a ROW of N vectors - the same coordinates, the
% wrong orientation, silently.
%
% See also
% vector3d vector3d.byXYZ

checkThreeArgumentShapes;
checkMatrixShapes;
checkAmbiguousAndInvalid;
checkNoInternalAmbiguity;
checkByXYZ;

disp('check_vector3d: passed');

end

% =========================================================================
function checkThreeArgumentShapes
% v = vector3d(x,y,z) has the shape of its coordinate arrays

n = 7;
x = rand(1,n); y = rand(1,n); z = rand(1,n);

assert(isequal(size(vector3d(x,y,z)),[1 n]), ...
  'vector3d from row coordinates is %s, expected [1 %d]', ...
  mat2str(size(vector3d(x,y,z))), n);

assert(isequal(size(vector3d(x.',y.',z.')),[n 1]), ...
  'vector3d from column coordinates is %s, expected [%d 1]', ...
  mat2str(size(vector3d(x.',y.',z.'))), n);

end

% =========================================================================
function checkMatrixShapes
% 3 x N gives a row, N x 3 gives a column, and both hold the same vectors

n = 7;
xyz = rand(3,n);

byCol = vector3d(xyz);      % one vector per column
byRow = vector3d(xyz.');    % one vector per row

assert(isequal(size(byCol),[1 n]), ...
  'vector3d of a 3 x %d matrix is %s, expected [1 %d]', ...
  n, mat2str(size(byCol)), n);

assert(isequal(size(byRow),[n 1]), ...
  'vector3d of a %d x 3 matrix is %s, expected [%d 1]', ...
  n, mat2str(size(byRow)), n);

% the transposition is the only difference - not the coordinates
dev = max(norm(byCol(:) - byRow(:)));
assert(dev == 0, ...
  'the two matrix readings give different vectors, off by %g', dev);

% and the N x 3 reading agrees with byXYZ, which always used it
dev = max(norm(byRow - vector3d.byXYZ(xyz.')));
assert(dev == 0, 'vector3d(N x 3) and byXYZ(N x 3) disagree by %g', dev);

% a single vector is a scalar either way round
for v = {[1 2 3], [1;2;3]}
  assert(isscalar(vector3d(v{1})), ...
    'vector3d of a %s coordinate triple is not scalar', mat2str(size(v{1})));
end

% N x 3 with N = 0 is an empty column, not an error
assert(isequal(size(vector3d(zeros(0,3))),[0 1]), ...
  'vector3d of a 0 x 3 matrix is %s, expected [0 1]', ...
  mat2str(size(vector3d(zeros(0,3)))));

end

% =========================================================================
function checkNoInternalAmbiguity
% MTEX's own code must never reach the 3 x 3 warning
%
% The three crystal axes are a 3 x 3 matrix, so calcAxis built one on every
% crystalSymmetry construction and the warning fired on one of the hottest
% paths in the toolbox - harmless, since the column reading it wanted is the
% one it got, but noisy on every single call. An ordinary test run does not
% catch that, because a warning does not fail anything; only promoting it
% does. Kept here rather than left to a manual sweep.

state = warning('error','MTEX:vector3d:ambiguousMatrix'); %#ok<CTPCT>
cleanup = onCleanup(@() warning(state)); %#ok<NASGU>

% The 'mineral' option is what routes through calcAxis's alignment branch,
% and that is the branch that built the 3 x 3. Without it the branch is not
% taken, so a bare crystalSymmetry(pg) does NOT catch the regression - which
% is exactly how it escaped the first time. Every real script passes it.
cases = {{'432','mineral','Austenite'}, {'m-3m','mineral','X'}, ...
  {'321','mineral','Quartz'}, {'622','mineral','X'}, {'2/m','mineral','X'}, ...
  {'1',[1 2 3],[80 90 100]*degree,'mineral','X'}};

for k = 1:numel(cases)
  try
    cs = crystalSymmetry(cases{k}{:});
    v = cs.aAxis + cs.bAxis + cs.cAxis; %#ok<NASGU>
  catch ME
    if strcmp(ME.identifier,'MTEX:vector3d:ambiguousMatrix')
      error(['check_vector3d: crystalSymmetry(''%s'',...) reaches the 3 x 3 '...
        'ambiguity warning - slice the matrix explicitly at that call site '...
        'instead of letting the constructor guess'], cases{k}{1});
    end
    rethrow(ME);
  end
end

end

% =========================================================================
function checkAmbiguousAndInvalid
% 3 x 3 satisfies both readings, and a matrix that is neither is rejected

lastwarn('');
w = warning('off','MTEX:vector3d:ambiguousMatrix');
cleanup = onCleanup(@() warning(w));

v = vector3d(rand(3,3));

[~,id] = lastwarn;
assert(strcmp(id,'MTEX:vector3d:ambiguousMatrix'), ...
  'a 3 x 3 matrix raised %s instead of MTEX:vector3d:ambiguousMatrix', id);

% ... and is read column wise, i.e. as the 3 x N case
assert(isequal(size(v),[1 3]), ...
  'the ambiguous 3 x 3 matrix gave %s, expected the column wise [1 3]', ...
  mat2str(size(v)));

try
  vector3d(rand(4,5));
  error('check_vector3d:noError','a 4 x 5 matrix of coordinates was accepted');
catch ME
  assert(strcmp(ME.identifier,'MTEX:vector3d:wrongSize'), ...
    'a 4 x 5 matrix raised %s instead of MTEX:vector3d:wrongSize', ME.identifier);
end

end

% =========================================================================
function checkByXYZ
% byXYZ takes N x 3 and N x 2, including empty, and rejects the rest
%
% The N x 2 branch used to pass the SCALAR 0 as the z coordinate and rely on
% the constructor repmat-ing it to the size of x and y. For an empty input
% there is no non singular size to repmat to, so z stayed 1 x 1 against a
% 0 x 1 x and y and the constructor threw "Coordinates have different size".
% grain2d/checkInside walked into it - it appended a zero column to a query
% that was already n x 3, so every call took the non-three-column branch,
% and an empty query set (fill with nothing left to fill) then errored.
% The appended column also silently discarded z on every other call, which
% is what the rejection below is for.

for n = [0 1 5]

  v = vector3d.byXYZ(zeros(n,2));
  assert(isequal(size(v),[n 1]), ...
    'byXYZ of a %d x 2 gave %s, expected [%d 1]', n, mat2str(size(v)), n);
  assert(all(v.z(:) == 0), 'byXYZ of a %d x 2 did not set z to zero', n);

  v = vector3d.byXYZ(zeros(n,3));
  assert(isequal(size(v),[n 1]), ...
    'byXYZ of a %d x 3 gave %s, expected [%d 1]', n, mat2str(size(v)), n);

end

% z is read, not dropped
v = vector3d.byXYZ([1 2 3; 4 5 6]);
assert(isequal(v.z(:).',[3 6]), 'byXYZ dropped the z column');

% anything else is a call site error, not a silent truncation to x and y
for d = {zeros(0,4), rand(3,4), rand(5,1)}
  try
    vector3d.byXYZ(d{1});
    error('check_vector3d:noError', ...
      'byXYZ accepted a %s matrix', mat2str(size(d{1})));
  catch ME
    assert(strcmp(ME.identifier,'MTEX:vector3d:wrongSize'), ...
      'byXYZ of a %s matrix raised %s instead of MTEX:vector3d:wrongSize', ...
      mat2str(size(d{1})), ME.identifier);
  end
end

end
