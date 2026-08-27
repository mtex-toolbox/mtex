function check_crystalAxes
% check the crystal axes calcAxis derives for each lattice and alignment
%
% Nothing owned this, although it decides the reference frame every Miller
% index, pole figure and EBSD orientation is expressed in. Written when
% calcAxis was restructured around the setups that occur in practice:
%
% * lattices whose axes are mutually orthogonal (orthorhombic, tetragonal,
%   cubic) have a*||a, b*||b, c*||c, so every alignment naming a or a* for x
%   and c or c* for z asks for one and the same frame - the scaled
%   coordinate axes
% * hexagonal and trigonal have exactly two setups in use, X||a* (the MTEX
%   default) and X||a (EDAX / TSL), the latter being the former turned 30
%   degree about c
% * monoclinic and triclinic, and anything naming b, m or d, still go
%   through the general transformation matrix
%
% See also
% crystalSymmetry Miller

checkOrthogonalLattices;
checkHexagonalSetups;
checkNamingDoesNotAlign;
checkGeneralPath;

disp('check_crystalAxes: passed');

end

% =========================================================================
function checkOrthogonalLattices
% the axes are the scaled coordinate axes, whatever a or a* is named

for pg = {'mmm','422','m-3m'}

  abc = [1 2 3];
  if ~strcmp(pg{1},'mmm'), abc = [2 2 3]; end
  if strcmp(pg{1},'m-3m'), abc = [2 2 2]; end

  ref = axesOf(crystalSymmetry(pg{1},abc));
  assert(max(abs(ref - diag(abc)),[],'all') < 1e-12, ...
    'check_crystalAxes: %s gives %s, expected diag(%s)', ...
    pg{1}, mat2str(ref,4), mat2str(abc));

  % naming either of a/a* and c/c* is the same request
  for opt = {{'X||a'},{'X||a*'},{'X||a','Z||c'},{'X||a*','Z||c'}, ...
      {'X||a','Z||c*'},{'EDAX'}}
    got = axesOf(crystalSymmetry(pg{1},abc,opt{1}{:}));
    assert(max(abs(got - ref),[],'all') < 1e-12, ...
      'check_crystalAxes: %s with %s differs from the default frame by %g', ...
      pg{1}, strjoin(opt{1},','), max(abs(got - ref),[],'all'));
  end
end

end

% =========================================================================
function checkHexagonalSetups
% the two setups, written down, and the 30 degree relation between them

a = 2; c = 3;

wantAStar = [a*sqrt(0.75) -a/2 0; 0 a 0; 0 0 c];   % X||a*, the default
wantA     = [a 0 0; -a/2 a*sqrt(0.75) 0; 0 0 c];   % X||a,  EDAX / TSL

for pg = {'321','6/mmm','3','-6m2'}

  got = axesOf(crystalSymmetry(pg{1},[a a c]));
  assert(max(abs(got - wantAStar),[],'all') < 1e-12, ...
    'check_crystalAxes: %s default frame is %s, expected %s', ...
    pg{1}, mat2str(got,4), mat2str(wantAStar,4));

  for opt = {{'X||a*'},{'X||a*','Z||c'}}
    got = axesOf(crystalSymmetry(pg{1},[a a c],opt{1}{:}));
    assert(max(abs(got - wantAStar),[],'all') < 1e-12, ...
      'check_crystalAxes: %s with %s is not the X||a* frame', ...
      pg{1}, strjoin(opt{1},','));
  end

  for opt = {{'X||a'},{'X||a','Z||c'},{'EDAX'},{'TSL'}}
    got = axesOf(crystalSymmetry(pg{1},[a a c],opt{1}{:}));
    assert(max(abs(got - wantA),[],'all') < 1e-12, ...
      'check_crystalAxes: %s with %s is %s, expected the X||a frame %s', ...
      pg{1}, strjoin(opt{1},','), mat2str(got,4), mat2str(wantA,4));
  end

  % the two differ by exactly 30 degree about c
  cs1 = crystalSymmetry(pg{1},[a a c]);
  cs2 = crystalSymmetry(pg{1},[a a c],'X||a');
  % as plain vectors - the two aAxis are Miller indices of different
  % symmetries, which angle would rightly complain about
  om = angle(vector3d(cs1.aAxis),vector3d(cs2.aAxis));
  assert(abs(om - 30*degree) < 1e-12, ...
    'check_crystalAxes: %s - the two setups are %g degree apart, expected 30', ...
    pg{1}, om/degree);
end

end

% =========================================================================
function checkNamingDoesNotAlign
% a 'mineral' or 'color' option is a string, but it is not an alignment
%
% Regression: every string option reached the alignment machinery, which
% found no axis to align, silently added Z||c and multiplied by the
% identity. Harmless in the result but it made naming a phase pay for the
% whole computation - and it is what pushed a 3 × 3 matrix through the
% vector3d constructor on every call, see check_vector3d.

for pg = {'m-3m','321','2/m','1'}

  abc = [1 2 3]; ang = [80 95 110]*degree;
  switch pg{1}
    case 'm-3m', abc = [2 2 2]; ang = [90 90 90]*degree;
    case '321',  abc = [2 2 3]; ang = [90 90 120]*degree;
    case '2/m',  ang = [90 100 90]*degree;
  end

  ref = axesOf(crystalSymmetry(pg{1},abc,ang));
  got = axesOf(crystalSymmetry(pg{1},abc,ang,'mineral','Test','color','red'));

  assert(isequal(got,ref), ...
    'check_crystalAxes: %s - naming the phase changed the axes by %g', ...
    pg{1}, max(abs(got - ref),[],'all'));
end

end

% =========================================================================
function checkGeneralPath
% monoclinic and triclinic still go through the transformation matrix
%
% There a and a* genuinely differ, so X||a is a real rotation and not the
% no-op it is for the orthogonal lattices - the fast paths must not swallow
% it. An over determined request still has to be rejected.

cs = crystalSymmetry('2/m',[1 2 3],[90 100 90]*degree);
csA = crystalSymmetry('2/m',[1 2 3],[90 100 90]*degree,'X||a');

assert(max(abs(axesOf(cs) - axesOf(csA)),[],'all') > 0.1, ...
  'check_crystalAxes: monoclinic X||a did not change the frame');

% x really is on a now
assert(angle(csA.aAxis,vector3d.X) < 1e-10, ...
  'check_crystalAxes: monoclinic X||a left a at %g degree from x', ...
  angle(csA.aAxis,vector3d.X)/degree);

% ... and on a* by default
assert(angle(cs.aAxisRec,vector3d.X) < 1e-10, ...
  'check_crystalAxes: the default frame does not put a* on x');

% an alignment that cannot be realised is still an error
try
  crystalSymmetry('1',[1 2 3],[80 95 110]*degree,'X||a','Z||c');
  error('check_crystalAxes:noError', ...
    'triclinic X||a together with Z||c was accepted');
catch ME
  assert(contains(ME.message,'Bad alignment options'), ...
    'check_crystalAxes: over determined alignment raised "%s"', ME.message);
end

end

% =========================================================================
function m = axesOf(cs)
m = [cs.aAxis.xyz; cs.bAxis.xyz; cs.cAxis.xyz];
end
