function check_Miller
% checks on crystal directions: index conventions, conversion and rounding
%
% Nothing in tests/ asserted anything about Miller indices at all, which is
% why this file exists - crystal directions are orientation geometry and
% every pole figure and IPF goes through them.
%
% The four index notation is where the traps are. For trigonal and hexagonal
% lattices the three and the four index forms are not integer at the same
% time: UVTW = (1,3,-4,8) is uvw = (5,7,8)/3. Which one round() makes
% integer is what the 'hkl' / 'hkil' / 'uvw' / 'UVTW' option selects, and by
% default it is the display convention of the input.
%
% See also
% Miller Miller/round MillerConvention

cs = crystalSymmetry('6/mmm',[3 3 5]);       % hexagonal, a != c
csT = crystalSymmetry('-3m',[4.9 4.9 5.4]);  % trigonal, quartz-like
csC = crystalSymmetry('m-3m');               % cubic

checkFourIndexConstraint(cs);
checkFourIndexConstraint(csT);
checkThreeFourRoundTrip(cs);
checkRoundConvention(cs);
checkRoundKeepsDirection(cs);
checkRoundKeepsDirection(csC);
checkDispStyleSurvives(cs);
checkCubicHklUvw(csC);
checkSymmetriseMultiplicity(cs);
checkSymmetriseMultiplicity(csC,[6 12 8 48]);  % the m-3m powder values

disp('check_Miller: passed');

end

% =========================================================================
function checkFourIndexConstraint(cs)
% the redundant third index is determined by the first two - i = -(h+k) for
% a plane, T = -(U+V) for a direction. A conversion that gets this wrong
% still produces a plausible looking vector.

rng(0)

h = Miller(round(5*randn(20,1)),round(5*randn(20,1)),round(5*randn(20,1)),cs,'hkl');
assert(max(abs(h.h + h.k + h.i)) < 1e-10, ...
  'check_Miller: %s - h + k + i is not 0, worst case %.3g', ...
  char(cs.pointGroup), max(abs(h.h + h.k + h.i)))

d = Miller(round(5*randn(20,1)),round(5*randn(20,1)),round(5*randn(20,1)),cs,'uvw');
assert(max(abs(d.U + d.V + d.T)) < 1e-10, ...
  'check_Miller: %s - U + V + T is not 0, worst case %.3g', ...
  char(cs.pointGroup), max(abs(d.U + d.V + d.T)))

end

% =========================================================================
function checkThreeFourRoundTrip(cs)
% reading a Miller in the other index count and building it back must give
% the same direction in space

rng(0)

h = Miller(round(4*randn(30,1)),round(4*randn(30,1)),round(4*randn(30,1)),cs,'hkl');
back = Miller(h.h,h.k,h.i,h.l,cs,'hkil');
assertParallel(h,back,'hkl -> hkil -> hkl')

d = Miller(round(4*randn(30,1)),round(4*randn(30,1)),round(4*randn(30,1)),cs,'uvw');
backD = Miller(d.U,d.V,d.T,d.W,cs,'UVTW');
assertParallel(d,backD,'uvw -> UVTW -> uvw')

end

% =========================================================================
function checkRoundConvention(cs)
% the case from the help text of Miller/round

h = Miller(1,3,-4,8,cs,'UVTW');

% as given, uvw is (5,7,8)/3 - not integer
uvw = [h.u h.v h.w];
assert(max(abs(uvw - [5 7 8]/3)) < 1e-10, ...
  'check_Miller: UVTW (1,3,-4,8) should be uvw (5,7,8)/3, got %s', mat2str(uvw,4))

% default: keep the display convention, UVTW, integer - so nothing changes
hDef = round(h);
assert(isequal([hDef.U hDef.V hDef.T hDef.W],[1 3 -4 8]), ...
  'check_Miller: round() changed an already integer UVTW to %s', ...
  mat2str([hDef.U hDef.V hDef.T hDef.W],4))

% asking for uvw makes the three index form integer instead
hUvw = round(h,'uvw');
assert(max(abs([hUvw.u hUvw.v hUvw.w] - [5 7 8])) < 1e-10, ...
  'check_Miller: round(h,''uvw'') should give uvw (5,7,8), got %s', ...
  mat2str([hUvw.u hUvw.v hUvw.w],4))

% and it must be the same direction, just scaled
assertParallel(h,hUvw,'round(h,''uvw'')')

% both forms cannot be integer at once, which is the whole point
assert(max(abs([hUvw.U hUvw.V hUvw.T hUvw.W] - round([hUvw.U hUvw.V hUvw.T hUvw.W]))) < 1e-10, ...
  'check_Miller: the uvw rounded form should still have integer UVTW here')
assert(~isequal([hUvw.U hUvw.V hUvw.T hUvw.W],[1 3 -4 8]), ...
  'check_Miller: round(h,''uvw'') left UVTW unchanged, so it did nothing')

end

% =========================================================================
function checkRoundKeepsDirection(cs)
% rounding may only shorten the indices, never turn the direction elsewhere

rng(0)

h = Miller(randn(40,1),randn(40,1),randn(40,1),cs,'hkl');
hr = round(h,'maxHKL',12);

% round is a rational approximation, so the direction moves a little - but
% it has to stay recognisably the same direction
d = angle(h,hr)/degree;
assert(max(d) < 5, ...
  'check_Miller: %s - round moved a direction by %.2f degree', ...
  char(cs.pointGroup), max(d))

% and the result really is integer in the convention it was asked for
m = [hr.h hr.k hr.l];
assert(max(abs(m - round(m)),[],'all') < 1e-9, ...
  'check_Miller: %s - round did not produce integer hkl', char(cs.pointGroup))

end

% =========================================================================
function checkDispStyleSurvives(cs)
% setting the coordinates inside round overwrites dispStyle, so round has to
% put it back - including when it was asked to round in another convention

for style = {'hkl','hkil','uvw','UVTW'}

  h = Miller(1,3,-4,8,cs,'UVTW');
  h.dispStyle = style{1};

  % NB h.dispStyle is a char, so == on two of them is an elementwise
  % comparison of the letters, not an identity test - and it errors outright
  % when the two names differ in length. Compare them as strings.
  hr = round(h);
  assert(strcmp(char(h.dispStyle),char(hr.dispStyle)), ...
    'check_Miller: round() changed the display convention from %s to %s', ...
    char(h.dispStyle), char(hr.dispStyle))

  hr2 = round(h,'uvw');
  assert(strcmp(char(h.dispStyle),char(hr2.dispStyle)), ...
    'check_Miller: round(h,''uvw'') changed the display convention from %s to %s', ...
    char(h.dispStyle), char(hr2.dispStyle))

end

end

% =========================================================================
function checkCubicHklUvw(cs)
% in a cubic lattice the plane normal (hkl) and the direction [uvw] with the
% same numbers point the same way - the standard sanity check that the
% structure matrix is being applied at all

for m = [1 0 0; 1 1 0; 1 1 1; 2 1 0].'

  hkl = Miller(m(1),m(2),m(3),cs,'hkl');
  uvw = Miller(m(1),m(2),m(3),cs,'uvw');

  assertParallel(hkl,uvw,sprintf('cubic (%d%d%d) plane vs direction',m))

end

end

% =========================================================================
function checkSymmetriseMultiplicity(cs,expected)
% multiplicity is the size of the orbit, and the orbit-stabilizer relation
%
% Until #2584 this returned the reciprocal - the order of the stabilizer -
% so cubic (100) came out as 8 while the form {100} has 6 members. Both
% halves are pinned: the value itself, and that it divides the group order.
% expected, when given, are the standard crystallographic multiplicities -
% the powder diffraction values, which is the whole point of the convention.

forms = [1 0 0; 1 1 0; 1 1 1; 3 2 1].';

for k = 1:size(forms,2)

  m = forms(:,k);
  h = Miller(m(1),m(2),m(3),cs,'hkl');
  n = length(symmetrise(h,'unique','noAntipodal'));

  assert(h.multiplicity == n, ...
    ['check_Miller: %s (%d%d%d) - multiplicity is %d but there are %d ' ...
     'symmetrically equivalent directions'], ...
    char(cs.pointGroup), m(1), m(2), m(3), h.multiplicity, n)

  assert(mod(numSym(cs),n) == 0, ...
    ['check_Miller: %s (%d%d%d) - %d equivalent directions does not ' ...
     'divide the group order %d'], ...
    char(cs.pointGroup), m(1), m(2), m(3), n, numSym(cs))

  if nargin > 1
    assert(h.multiplicity == expected(k), ...
      'check_Miller: %s {%d%d%d} multiplicity is %d, expected %d', ...
      char(cs.pointGroup), m(1), m(2), m(3), h.multiplicity, expected(k))
  end

end

end

% =========================================================================
function assertParallel(a,b,what)
% same direction up to a positive scale

na = normalize(vector3d(a));
nb = normalize(vector3d(b));

dev = 1 - abs(dot(na(:),nb(:)));

assert(max(dev) < 1e-10, ...
  'check_Miller: %s is not the same direction, 1 - |dot| up to %.3g', ...
  what, max(dev))

end
