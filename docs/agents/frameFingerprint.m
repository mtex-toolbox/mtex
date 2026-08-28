% a numeric fingerprint of every symmetry and reference frame carrier
%
% Prints one |name = %.12g| line per observable, so two builds of MTEX can be
% compared with |diff|. It is the safety net for the ADR 0008 increments
% (docs/agents/adr-0008-implementation-plan.md): from the increment that makes
% |ori.CS| return a frame, the test tiers go red by design and cannot say
% whether a number moved. A fingerprint is type agnostic and can.
%
% Run it by absolute path, so both sides execute the same script text:
%
%   run('/path/to/mtex/docs/agents/frameFingerprint.m')
%
% Everything here is deterministic: fixed inputs in a fixed order, a seeded
% generator, and only |mtexdata| sets whose source files are in the repository.
% Nothing whose value is a class name or a handle is ever printed - those
% change on purpose. Frame identity appears as a 0/1 comparison instead.
%
% Each observable is probed separately and prints |name = ERROR| when it
% throws, so a carrier that is mid conversion does not blind the rest.
%
% The last three blocks read datasets through <mtexdata.html |mtexdata|>, which
% caches its result as |data/<name>.mat| in the worktree it ran in. A cache
% outlives a change to an importer or to the ODF solver, so run |mtexdata clear|
% on both sides before trusting a baseline taken across such a change.
%
% See also
% referenceFrame/reset

fpBlocks = {'symmetry',@fpSymmetry; 'frame',@fpFrame; 'miller',@fpMiller; ...
  'vector',@fpVector; 'ori',@fpOrientation; 'so3fun',@fpSO3Fun; ...
  's2fun',@fpS2Fun; 'tensor',@fpTensor; 'pf',@fpPoleFigure; 'ebsd',@fpEBSD};

for fpK = 1:size(fpBlocks,1)

  % the session default frame and the frame register are process state, and
  % an EBSD import writes into both - so every block starts from the same one
  close('all','force'); rng('default'); referenceFrame.reset;
  fpEmit([fpBlocks{fpK,1} '.sessionConvention'],double(char(plottingConvention.default)));

  try
    fpBlocks{fpK,2}();
  catch
    fprintf('%s = ERROR\n',fpBlocks{fpK,1});
  end
end


% -------------------------------------------------------------------------
function fpSymmetry

cs = fpCrystalSymmetries;
names = fieldnames(cs);

for k = 1:numel(names)
  s = cs.(names{k});
  p = ['symmetry.' names{k}];

  fpProbe([p '.id'],@() s.id);
  fpProbe([p '.LaueId'],@() s.Laue.id);
  fpProbe([p '.properId'],@() s.properGroup.id);
  fpProbe([p '.numSym'],@() numSym(s));
  fpProbe([p '.numProper'],@() numProper(s));
  fpProbe([p '.isLaue'],@() double(isLaue(s)));
  fpProbe([p '.isProper'],@() double(isProper(s)));
  fpProbe([p '.multiplicityZ'],@() s.multiplicityZ);
  fpProbe([p '.multiplicityPerpZ'],@() s.multiplicityPerpZ);
  fpProbe([p '.nfold'],@() nfold(s));
  fpProbe([p '.maxAngle'],@() maxAngle(s)./degree);
  fpProbe([p '.rotAngle'],@() sort(round(angle(s.rot)./degree*1e6)/1e6));
  fpProbe([p '.axes'],@() fpXYZ(s.axes));
  fpProbe([p '.abc'],@() s.abc);
  fpProbe([p '.abg'],@() s.abg./degree);
  fpProbe([p '.subGroupOfCubic'],@() double(s <= fpCubic));
end

ss = {specimenSymmetry('1'),specimenSymmetry('mmm'),specimenSymmetry('222')};
for k = 1:numel(ss)
  p = ['symmetry.specimen' int2str(k)];
  fpProbe([p '.id'],@() ss{k}.id);
  fpProbe([p '.numSym'],@() numSym(ss{k}));
  fpProbe([p '.rotAngle'],@() sort(round(angle(ss{k}.rot)./degree*1e6)/1e6));
end

end

% -------------------------------------------------------------------------
function fpFrame

cs = fpCrystalSymmetries;
names = fieldnames(cs);

for k = 1:numel(names)
  fr = cs.(names{k});
  p = ['frame.' names{k}];

  fpProbe([p '.basis'],@() fpXYZ(fr.basis));
  fpProbe([p '.basisDual'],@() fpXYZ(basisDual(fr)));
  fpProbe([p '.abc'],@() fr.abc);
  fpProbe([p '.abg'],@() fr.abg./degree);
end

% a transition matrix is nine numbers that depend on both bases - the single
% most sensitive frame observable there is
for k = 1:numel(names)
  for l = 1:numel(names)
    fr1 = cs.(names{k}); fr2 = cs.(names{l});
    p = ['frame.' names{k} '2' names{l}];
    fpProbe([p '.M'],@() transformationMatrix(fr1,fr2));
    fpProbe([p '.isAligned'],@() double(isAligned(fr1,fr2)));
    fpProbe([p '.isCompatible'],@() double(isCompatible(fr1,fr2)));
    fpProbe([p '.eq'],@() double(fr1 == fr2));
  end
end

fpProbe('frame.tolAligned',@() referenceFrame.tolAligned);
fpProbe('frame.tolCompatible',@() referenceFrame.tolCompatible);

% the named specimen frames come out of the register, so this also states
% that two lookups of one name are one frame
sf = {specimenFrame.specimen,specimenFrame.measurement,specimenFrame.rolling};
for k = 1:numel(sf)
  p = ['frame.specimen' int2str(k)];
  fpProbe([p '.basis'],@() fpXYZ(sf{k}.basis));
  fpProbe([p '.registered'],@() double(sf{k} == referenceFrame.byName(sf{k}.name)));
end
fpProbe('frame.specimenDistinct',@() double([sf{1}==sf{2},sf{1}==sf{3},sf{2}==sf{3}]));

% two constructions of one lattice: whether they unify is what interning
% changes, and it has to be visible before it does
cubicAxes = fpCubic;
cubicAxes = cubicAxes.axes;
frA = crystalFrame(cubicAxes,'name','fp');
frB = crystalFrame(cubicAxes,'name','fp');
fpProbe('frame.twoConstructions.eq',@() double(frA == frB));
fpProbe('frame.twoConstructions.isAligned',@() double(isAligned(frA,frB)));

% the register key of rule 2: what unifies two constructions and what does
% not. Colour is deliberately absent from it
iA = crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Interned');
fpProbe('frame.intern.same',@() double(iA == ...
  crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Interned')));
fpProbe('frame.intern.scaledCell',@() double(iA == ...
  crystalSymmetry('m-3m',[4.06 4.06 4.06],'mineral','Interned')));
fpProbe('frame.intern.otherColour',@() double(iA == ...
  crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Interned','color','green')));
fpProbe('frame.intern.otherMineral',@() double(iA == ...
  crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Other')));
fpProbe('frame.intern.otherGroup',@() double(iA == ...
  crystalSymmetry('432',[4.05 4.05 4.05],'mineral','Interned')));
fpProbe('frame.intern.otherShape',@() double( ...
  crystalSymmetry('mmm',[4.7 10.2 6.0],'mineral','Shape') == ...
  crystalSymmetry('mmm',[4.7 10.6 6.0],'mineral','Shape')));
fpProbe('frame.intern.bypass',@() double(iA == ...
  crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Interned','noIntern')));
fpProbe('frame.intern.specimen',@() double( ...
  specimenSymmetry('mmm') == specimenSymmetry('mmm')));

% how many groups one frame handle carries. A symmetry, its Laue class, its
% proper group and its group-stripped stand-in all point at one frame today,
% and every specimen symmetry points at the session default - which is what
% has to give when the group moves onto the frame. Whether the predicates
% built on that sharing still answer the same is the question this asks
for k = 1:numel(names)
  s = cs.(names{k});
  p = ['frame.sharing.' names{k}];
  rel = {'Laue',s.Laue; 'proper',s.properGroup; 'stripped',stripSym(s)};
  for l = 1:size(rel,1)
    o = rel{l,2}; q = [p '.' rel{l,1}];
    fpProbe([q '.eq'],@() double(s == o));
    fpProbe([q '.isAligned'],@() double(isAligned(s,o)));
    fpProbe([q '.isCompatible'],@() double(isCompatible(s,o)));
    fpProbe([q '.eqTol'],@() double(eqTol(s,o)));
    fpProbe([q '.sim'],@() double(sim(s,o)));
    fpProbe([q '.id'],@() [o.id,o.Laue.id,numSym(o)]);
    fpProbe([q '.multiplicity'],@() [o.multiplicityZ,o.multiplicityPerpZ]);
  end
end

ss = {specimenSymmetry('1'),specimenSymmetry('mmm'),specimenSymmetry('222')};
for k = 1:numel(ss)
  for l = 1:numel(ss)
    p = sprintf('frame.sharing.specimen%d%d',k,l);
    fpProbe([p '.eq'],@() double(ss{k} == ss{l}));
    fpProbe([p '.isAligned'],@() double(isAligned(ss{k},ss{l})));
    fpProbe([p '.eqTol'],@() double(eqTol(ss{k},ss{l})));
    fpProbe([p '.sim'],@() double(sim(ss{k},ss{l})));
  end
  fpProbe(sprintf('frame.sharing.specimen%d.isDefault',k), ...
    @() double(ss{k} == specimenFrame.default));
end

end

% -------------------------------------------------------------------------
function fpMiller

cs = fpCrystalSymmetries;
names = fieldnames(cs);
hkl = [1 0 0; 1 1 0; 1 1 1; 3 2 1; 2 -1 0];

for k = 1:numel(names)
  s = cs.(names{k});
  for l = 1:size(hkl,1)
    p = sprintf('miller.%s.%d',names{k},l);
    m = Miller(hkl(l,1),hkl(l,2),hkl(l,3),s,'hkl');
    u = Miller(hkl(l,1),hkl(l,2),hkl(l,3),s,'uvw');

    fpProbe([p '.hkl.xyz'],@() fpXYZ(m));
    fpProbe([p '.uvw.xyz'],@() fpXYZ(u));
    fpProbe([p '.hkl.dspacing'],@() dspacing(m));
    fpProbe([p '.hkl.multiplicity'],@() multiplicity(m));
    fpProbe([p '.hkl.numSymmetrise'],@() length(symmetrise(m)));
    fpProbe([p '.hkl.numSymmetriseUnique'],@() length(symmetrise(m,'unique')));
    fpProbe([p '.hkl2uvw.angle'],@() angle(m,u)./degree);
    mr = round(m,'hkl'); ur = round(u,'uvw');
    fpProbe([p '.hkl.roundHKL'],@() mr.hkl);
    fpProbe([p '.uvw.roundUVW'],@() ur.uvw);
  end

  % pairwise angles reduce over the group - rule 10's observable
  m1 = Miller(1,0,0,s,'hkl'); m2 = Miller(0,1,0,s,'hkl');
  fpProbe(['miller.' names{k} '.crossAngle'],@() angle(m1,m2)./degree);
  fpProbe(['miller.' names{k} '.crossAngleNoSym'],@() angle(m1,m2,'noSymmetry')./degree);
  fpProbe(['miller.' names{k} '.zone'],@() fpXYZ(cross(m1,m2)));
end

end

% -------------------------------------------------------------------------
function fpVector

v = vector3d([1 -2 0.5 3],[0 1 -1 2],[2 0.5 1 -3]);
w = vector3d(1,1,1);

fpProbe('vector.norm',@() norm(v));
fpProbe('vector.xyz',@() fpXYZ(v));
fpProbe('vector.angle',@() angle(v,w)./degree);
fpProbe('vector.dot',@() dot(v,w));
fpProbe('vector.cross',@() fpXYZ(cross(v,w)));
fpProbe('vector.mean',@() fpXYZ(mean(v)));
fpProbe('vector.sum',@() fpXYZ(sum(v)));

[theta,rho] = polar(v);
fpProbe('vector.theta',@() theta./degree);
fpProbe('vector.rho',@() rho./degree);

rot = rotation.byAxisAngle(vector3d(1,2,3),37*degree);
fpProbe('vector.rotated',@() fpXYZ(rot .* v));
fpProbe('vector.orth',@() fpXYZ(orth(v)));

fpProbe('rotation.angle',@() angle(rot)./degree);
fpProbe('rotation.axis',@() fpXYZ(rot.axis));
fpProbe('rotation.matrix',@() matrix(rot));
fpProbe('rotation.euler',@() cell2mat(fpEuler(rot))./degree);
fpProbe('rotation.rodrigues',@() fpXYZ(Rodrigues(rot)));

end

% -------------------------------------------------------------------------
function fpOrientation

cs = fpCrystalSymmetries;
names = fieldnames(cs);
euler = [10 20 30; 155 65 20; 0 0 0; 90 90 90; 37 12 199];

for k = 1:numel(names)
  s = cs.(names{k});
  ss = specimenSymmetry('1');
  p = ['ori.' names{k}];

  ori = orientation.byEuler(euler(:,1)*degree,euler(:,2)*degree,euler(:,3)*degree,s,ss);
  ref = orientation.byEuler(45*degree,45*degree,45*degree,s,ss);

  fpProbe([p '.angle'],@() angle(ori)./degree);
  fpProbe([p '.angleNoSym'],@() angle(ori,'noSymmetry')./degree);
  fpProbe([p '.angleToRef'],@() angle(ori,ref)./degree);
  fpProbe([p '.axisToRef'],@() fpXYZ(axis(ori,ref)));
  fpProbe([p '.matrix'],@() matrix(ori(2)));
  fpProbe([p '.numSymmetrise'],@() length(symmetrise(ori(1))));
  fpProbe([p '.inv.angle'],@() angle(inv(ori))./degree);
  fpProbe([p '.fundamental'],@() angle(project2FundamentalRegion(ori))./degree);
  fpProbe([p '.euler'],@() cell2mat(fpEuler(project2FundamentalRegion(ori)))./degree);
  fpProbe([p '.dotRef'],@() dot(ori,ref));
  fpProbe([p '.volume'],@() volume(ori,ref,20*degree));

  % the mean is order dependent through its reference, so only the angle to
  % a fixed orientation and the sorted moments are printed, never eigenvectors
  fpProbe([p '.meanAngle'],@() angle(mean(ori),ref)./degree);
  [~,~,lambda] = mean(ori);
  fpProbe([p '.meanLambda'],@() sort(lambda(:)));

  % a misorientation has a crystal frame on both sides
  mori = inv(ori(1)) .* ori(2);
  fpProbe([p '.mori.angle'],@() angle(mori)./degree);
  fpProbe([p '.mori.axis'],@() fpXYZ(mori.axis));
  fpProbe([p '.mori.numSymmetrise'],@() length(symmetrise(mori)));

  % a direction pushed through an orientation is the frame change itself
  fpProbe([p '.pushMiller'],@() fpXYZ(ori(2) .* Miller(1,1,1,s,'hkl')));
end

end

% -------------------------------------------------------------------------
function fpSO3Fun

cs = fpCubic; ss = specimenSymmetry('1');
nodes = orientation.byEuler([0 25 80 130]*degree,[0 40 15 70]*degree, ...
  [0 10 55 95]*degree,cs,ss);

odf = unimodalODF(orientation.byEuler(15*degree,30*degree,45*degree,cs,ss), ...
  'halfwidth',10*degree);
fib = fibreODF(Miller(0,0,1,cs),zvector,cs,ss,'halfwidth',10*degree);

fpProbe('so3fun.uni.eval',@() odf.eval(nodes));
fpProbe('so3fun.uni.norm',@() norm(odf));
fpProbe('so3fun.uni.entropy',@() entropy(odf));
fpProbe('so3fun.uni.mean',@() mean(odf));
fpProbe('so3fun.uni.bandwidth',@() odf.bandwidth);
fpProbe('so3fun.uni.volume',@() volume(odf,nodes(2),15*degree));
fpProbe('so3fun.uni.numSymLeft',@() numSym(odf.SLeft));
fpProbe('so3fun.uni.numSymRight',@() numSym(odf.SRight));

fpProbe('so3fun.fib.eval',@() fib.eval(nodes));
fpProbe('so3fun.fib.norm',@() norm(fib));
fpProbe('so3fun.fib.entropy',@() entropy(fib));

sumOdf = odf + fib;
fpProbe('so3fun.sum.eval',@() sumOdf.eval(nodes));

harm = fpQuiet(@() SO3FunHarmonic(odf,'bandwidth',24));
fpProbe('so3fun.harm.eval',@() harm.eval(nodes));
fpProbe('so3fun.harm.fhat',@() real(fpFirst(harm.fhat,40)));
fpProbe('so3fun.harm.bandwidth',@() harm.bandwidth);

dubna = fpQuiet(@() SO3Fun.dubna);
fpProbe('so3fun.dubna.eval',@() dubna.eval(nodes));
fpProbe('so3fun.dubna.norm',@() norm(dubna));

fpProbe('so3fun.pdf',@() calcPDF(odf,Miller(1,0,0,cs),fpDirections));

end

% -------------------------------------------------------------------------
function fpS2Fun

v = fpDirections;

smiley = fpQuiet(@() S2Fun.smiley);
fpProbe('s2fun.smiley.eval',@() smiley.eval(v));
fpProbe('s2fun.smiley.mean',@() mean(smiley));
fpProbe('s2fun.smiley.norm',@() norm(smiley));

sF = fpQuiet(@() S2FunHarmonic.quadrature(@(x) exp(-2*angle(x,zvector).^2),'bandwidth',24));
fpProbe('s2fun.harm.eval',@() sF.eval(v));
fpProbe('s2fun.harm.mean',@() mean(sF));
fpProbe('s2fun.harm.norm',@() norm(sF));
fpProbe('s2fun.harm.bandwidth',@() sF.bandwidth);
fpProbe('s2fun.harm.fhat',@() real(fpFirst(sF.fhat,25)));

cs = fpCubic;
sFsym = fpQuiet(@() S2FunHarmonic.quadrature(@(x) exp(-2*angle(x,zvector).^2),cs));
fpProbe('s2fun.sym.eval',@() sFsym.eval(v));
fpProbe('s2fun.sym.mean',@() mean(sFsym));

end

% -------------------------------------------------------------------------
function fpTensor

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Forsterite');
M = [[320.5 68.15 71.6 0 0 0];...
  [68.15 196.5 76.8 0 0 0];...
  [71.6 76.8 233.5 0 0 0];...
  [0 0 0 64 0 0];...
  [0 0 0 0 77 0];...
  [0 0 0 0 0 78.7]];
C = stiffnessTensor(M,cs);
v = fpDirections;
ori = orientation.byEuler(15*degree,30*degree,45*degree,cs);

fpProbe('tensor.M',@() C.M(:));
fpProbe('tensor.norm',@() norm(C));
fpProbe('tensor.rotated',@() fpFirst(reshape(double(rotate(C,ori)),[],1),81));
fpProbe('tensor.youngs',@() C.YoungsModulus(v));
fpProbe('tensor.shear',@() C.shearModulus(v,rotate(v,rotation.byAxisAngle(v,90*degree))));
fpProbe('tensor.bulk',@() C.bulkModulus);
fpProbe('tensor.linCompress',@() C.linearCompressibility(v));
fpProbe('tensor.eig',@() sort(eig(C)));

S = inv(C);
fpProbe('tensor.compliance',@() S.M(:));
fpProbe('tensor.poisson',@() S.PoissonRatio(v,rotate(v,rotation.byAxisAngle(v,90*degree))));

odf = unimodalODF(ori,'halfwidth',15*degree);
Cbar = fpQuiet(@() calcTensor(odf,C));
fpProbe('tensor.calcTensor',@() Cbar.M(:));

end

% -------------------------------------------------------------------------
function fpPoleFigure

cs = fpCubic; ss = specimenSymmetry('1');
odf = unimodalODF(orientation.byEuler(15*degree,30*degree,45*degree,cs,ss), ...
  'halfwidth',10*degree);
r = regularS2Grid('resolution',15*degree,'antipodal');
h = {Miller(1,0,0,cs),Miller(1,1,0,cs),Miller(1,1,1,cs)};

pf = fpQuiet(@() calcPoleFigure(odf,h,r));
fpProbe('pf.numR',@() length(pf.r));
fpProbe('pf.min',@() min(pf));
fpProbe('pf.max',@() max(pf));
fpProbe('pf.mean',@() mean(pf));
fpProbe('pf.intensityHead',@() fpFirst(pf.intensities(:),60));
fpProbe('pf.numSymSS',@() numSym(pf.SS));

pfx = fpQuiet(@() mtexdata('ptx','silent'));
fpProbe('pf.ptx.numR',@() length(pfx.r));
fpProbe('pf.ptx.min',@() min(pfx));
fpProbe('pf.ptx.max',@() max(pfx));
fpProbe('pf.ptx.mean',@() mean(pfx));
fpProbe('pf.ptx.h',@() fpXYZ([pfx.allH{:}]));
fpProbe('pf.ptx.numSymCS',@() numSym(pfx.CS));

end

% -------------------------------------------------------------------------
function fpEBSD

ebsd = fpQuiet(@() mtexdata('small','silent'));

fpProbe('ebsd.length',@() length(ebsd));
fpProbe('ebsd.extent',@() ebsd.extent);
fpProbe('ebsd.numPhase',@() length(ebsd.CSList));
fpProbe('ebsd.phaseSizes',@() sort(histcounts(ebsd.phaseId,0.5:1:(length(ebsd.CSList)+0.5)))');
fpProbe('ebsd.unitCell',@() fpXYZ(ebsd.unitCell));
fpProbe('ebsd.N',@() fpXYZ(ebsd.N));

ebsdIdx = ebsd('indexed');
grains = fpQuiet(@() calcGrains(ebsdIdx,'angle',10*degree));
fpProbe('grains.number',@() length(grains));
fpProbe('grains.totalArea',@() sum(grains.area));
fpProbe('grains.areaHead',@() fpFirst(sort(grains.area,'descend'),25));
fpProbe('grains.perimeter',@() sum(grains.perimeter));
fpProbe('grains.boundarySize',@() sum(grains.boundarySize));
fpProbe('grains.numBoundary',@() length(grains.boundary));
fpProbe('grains.gosHead',@() fpFirst(sort(grains.GOS./degree,'descend'),25));

% orientations only exist per phase - a multi phase map has no single
% crystal frame to express them in, which is rule 13 seen from the data side
mins = ebsd.mineralList;
for k = ebsd.indexedPhasesId

  p = ['ebsd.' mins{k}];
  e = ebsd(mins{k});
  g = grains(mins{k});
  gb = grains.boundary(mins{k},mins{k});

  fpProbe([p '.count'],@() length(e));
  fpProbe([p '.numSym'],@() numSym(e.CS));
  fpProbe([p '.abc'],@() e.CS.abc);
  fpProbe([p '.oriAngleHead'],@() fpFirst(sort(angle(e.orientations)./degree),30));
  fpProbe([p '.meanOriAngle'],@() angle(mean(e.orientations))./degree);
  fpProbe([p '.grainCount'],@() length(g));
  fpProbe([p '.grainArea'],@() sum(g.area));
  fpProbe([p '.meanOriAngleHead'],@() fpFirst(sort(angle(g.meanOrientation)./degree),20));
  fpProbe([p '.numSegment'],@() length(gb));
  fpProbe([p '.segLength'],@() sum(gb.segLength));
  fpProbe([p '.misAngleHead'],@() fpFirst(sort(gb.misorientation.angle./degree,'descend'),30));
end

end


% ---------------------------- helpers ------------------------------------
function cs = fpCrystalSymmetries
% one representative of each lattice type, with real lattice parameters -
% the cubic one is where a canonical basis would hide a frame defect

cs.cubic = crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Aluminium');
cs.cubic23 = crystalSymmetry('23',[5.43 5.43 5.43],'mineral','Cubic23');
cs.hex = crystalSymmetry('6/mmm',[2.95 2.95 4.686],'mineral','Titanium');
cs.trigonal = crystalSymmetry('-3m',[4.913 4.913 5.405],'mineral','Quartz');
cs.tetra = crystalSymmetry('4/mmm',[4.594 4.594 2.959],'mineral','Rutile');
cs.ortho = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Forsterite');
cs.mono = crystalSymmetry('2/m',[9.746 8.99 5.27],[90 105.63 90]*degree,'mineral','Diopside');
cs.tric = crystalSymmetry('-1',[8.17 12.87 7.11],[93.1 116.0 89.5]*degree,'mineral','Albite');
cs.triv = crystalSymmetry('1',[4.05 4.05 4.05],'mineral','Trivial');

end

function cs = fpCubic
cs = crystalSymmetry('m-3m',[4.05 4.05 4.05],'mineral','Aluminium');
end

function v = fpDirections
% a fixed, non symmetric set of specimen directions
v = vector3d([1 0 0 1 1 1 2 -1],[0 1 0 1 0 1 1 3],[0 0 1 0 1 1 3 2]);
end

function e = fpEuler(r)
[a,b,c] = Euler(r);
e = {a(:),b(:),c(:)};
end

function x = fpFirst(v,n)
% a stable head of a long vector - the whole of it would drown the diff
v = v(:);
x = v(1:min(n,numel(v)));
end

function m = fpXYZ(v)
m = [v.x(:),v.y(:),v.z(:)];
end

function fpProbe(name,f)
% evalc keeps whatever the observable prints out of the stream - a solver
% that reports its iterations would otherwise land between two numbers
try
  evalc('fpValue = f();');
  fpEmit(name,fpValue);
catch
  fprintf('%s = ERROR\n',name);
end
end

function out = fpQuiet(f)
% the same, for a fixture: mtexdata announces the cache it writes on first
% load, so a cold worktree would print where a warm one does not
evalc('out = f();');
end

function fpEmit(name,value)
% snapped to an absolute grid of 1e-12 before printing. Some observables are
% evaluations near a zero of the function, so a computation whose own scale is
% one lands at 1e-6 and its last digits are summation-order noise that moves
% between processes. The grid is three orders above that noise and leaves every
% digit of anything larger
value = double(value);
value = round(value(:),12);
if isscalar(value)
  fprintf('%s = %.12g\n',name,value);
else
  for k = 1:numel(value)
    fprintf('%s(%d) = %.12g\n',name,k,value(k));
  end
end
end
