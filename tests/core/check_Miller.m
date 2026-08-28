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
% Miller vector3d/round MillerConvention

cs = crystalFrame('6/mmm',[3 3 5]);       % hexagonal, a != c
csT = crystalFrame('-3m',[4.9 4.9 5.4]);  % trigonal, quartz-like
csC = crystalFrame('m-3m');               % cubic

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
checkFamilyBrackets(csC);
checkParsedBrackets(csC);
checkCrystalDirection;

disp('check_Miller: passed');

end

% =========================================================================
function checkFamilyBrackets(cs)
% a point group makes the indices stand for the whole equivalent set, and
% the literature writes that in the family brackets - so the brackets are
% what tell a reader that == and angle reduce over the group

assert(strcmp(char(Miller(1,1,1,cs,'hkl')),'{111}'), ...
  'check_Miller: a plane in a point group is not written {111}, but %s', ...
  char(Miller(1,1,1,cs,'hkl')))
assert(strcmp(char(Miller(1,0,0,cs,'uvw')),'<100>'), ...
  'check_Miller: a direction in a point group is not written <100>, but %s', ...
  char(Miller(1,0,0,cs,'uvw')))

% the trivial group leaves one plane and one direction
cs1 = crystalFrame('1',cs.axes);
assert(strcmp(char(Miller(1,1,1,cs1,'hkl')),'(111)'), ...
  'check_Miller: a plane under the trivial group is not written (111), but %s', ...
  char(Miller(1,1,1,cs1,'hkl')))
assert(strcmp(char(Miller(1,0,0,cs1,'uvw')),'[100]'), ...
  'check_Miller: a direction under the trivial group is not written [100], but %s', ...
  char(Miller(1,0,0,cs1,'uvw')))

% the bracket follows the sign of the convention, so the four index forms
% take the same pair
csH = crystalFrame('6/mmm',[3 3 5]);
c = char(Miller(1,0,-1,0,csH,'hkil'),'noUTF8');
assert(c(1) == '{' && c(end) == '}', ...
  'check_Miller: a four index plane family is not written in braces, but %s',c)

end

% =========================================================================
function checkParsedBrackets(cs)
% both direct brackets mean uvw and both reciprocal ones hkl - <100> read as
% a plane normal for as long as the parser tested for '[' alone

assertParallel(Miller('<100>',cs),Miller('[100]',cs),'<100> against [100]')
assertParallel(Miller('{110}',cs),Miller('(110)',cs),'{110} against (110)')

m = Miller('<100>',cs);
assert(m.dispStyle == MillerConvention.uvw, ...
  'check_Miller: <100> did not parse as a direction')
m = Miller('{110}',cs);
assert(m.dispStyle == MillerConvention.hkl, ...
  'check_Miller: {110} did not parse as a plane normal')

% the other half of the pair says how many directions are meant
for form = {'(100)','[100]'}
  m = Miller(form{1},cs);
  assert(m.CS.id == 1 && isscalar(symmetrise(m)), ...
    'check_Miller: %s is a single direction, but carries %s', ...
    form{1}, m.CS.pointGroup)
end

for form = {'{100}','<100>'}
  m = Miller(form{1},cs);
  assert(m.CS.id == cs.id && numel(symmetrise(m)) == numSym(cs), ...
    'check_Miller: %s is a family, but carries %s',form{1},m.CS.pointGroup)
end

% the lattice survives the dropped group, so the indices still read back
assertParallel(Miller('(110)',cs),Miller(1,1,0,cs),'(110) against Miller(1,1,0)')

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
% the case from the help text of vector3d/round

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

  % dispStyle is a char, so == compares the letters and errors on different lengths
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

% =========================================================================
function checkCrystalDirection
% isCrystalDirection asks the object, not its class - which is what lets it
% survive @Miller becoming an ordinary framed @vector3d

cs = crystalFrame('m-3m',[4.05 4.05 4.05],'mineral','Al');

assert(isCrystalDirection(Miller(1,0,0,cs)), ...
  'check_Miller: a Miller is a crystal direction')
assert(~isCrystalDirection(xvector), ...
  'check_Miller: a frame-free vector is not a crystal direction')

% a specimen frame has no indices to give
v = xvector; v.frame = specimenFrame.rolling;
assert(~isCrystalDirection(v), ...
  'check_Miller: a specimen framed vector is not a crystal direction')

% and it is the frame that decides, not the class - a plain vector3d put in
% a crystal frame answers the same as the Miller does
w = xvector; w.frame = cs;
assert(isCrystalDirection(w), ...
  'check_Miller: a crystal framed vector3d is a crystal direction')

assert(~isCrystalDirection(cs) && ~isCrystalDirection('hkl'), ...
  'check_Miller: only a vector can be a crystal direction')

end
