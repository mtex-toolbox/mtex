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
