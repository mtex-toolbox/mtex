function check_MLSFun
% check S2FunMLS and SO3FunMLS, the moving least squares functions
%
% Both classes share their machinery through @MLSFun. A function from the
% ansatz space is reproduced exactly by every local fit, whatever the
% neighborhoods look like, so most checks compare against such a function.
%
% Optimal subsampling, which runs a linear program per center, is checked
% in slow/check_MLSSubsample.
%
% See also
% S2FunMLS SO3FunMLS check_MLSSubsample

rng(0)

checkS2Reproduction
checkSO3Reproduction
checkOddDegree
checkConstruction
checkAntipodalSearch
checkAntipodalMisorientation
checkVariableSizeSolver

disp('check_MLSFun: everything ok!')

end

% -------------------------------------------------------------------------
function checkS2Reproduction
% every S2 mode reproduces a polynomial of the ansatz space

% the ansatz of degree L holds the harmonics with the parity of L
v = vector3d.rand(500);
w = vector3d.rand(30);
p2 = @(x) x.x.^2 + 2*x.y.*x.z - 0.3*x.z.^2 + 0.5;
p3 = @(x) x.x.^3 - x.x.*x.y.*x.z + x.y;
noReg = {'regularize',false,'use_smooth_delta',false};

F = S2FunMLS(v,p2(v),'degree',2,noReg{:});
assertAlmostEqual(F.eval(w),p2(w),'S2FunMLS, centered monomials')
assert(F.dim == 6,'S2FunMLS: wrong ansatz dimension')

F = S2FunMLS(v,p2(v),'degree',2,'centered',false,noReg{:});
assertAlmostEqual(F.eval(w),p2(w),'S2FunMLS, global monomials')

F = S2FunMLS(v,p2(v),'degree',2,'centered',false,'monomials',false,noReg{:});
assertAlmostEqual(F.eval(w),p2(w),'S2FunMLS, spherical harmonics')

F = S2FunMLS(v,p2(v),'degree',2,'regularize',false);
assertAlmostEqual(F.eval(w),p2(w),'S2FunMLS, smooth support radius')

F.delta = F.compute_delta;
assertAlmostEqual(F.eval(w),p2(w),'S2FunMLS, range search')

F = S2FunMLS(v,p3(v),'degree',3,noReg{:});
assertAlmostEqual(F.eval(w),p3(w),'S2FunMLS, odd degree')
assert(F.dim == 10,'S2FunMLS: wrong ansatz dimension')

F = S2FunMLS(v,2*ones(size(v)),'degree',0);
assertAlmostEqual(F.eval(w),2,'S2FunMLS, degree zero')

% a radius that leaves centers without nodes, they take their nearest nodes
F.delta = F.compute_delta / 3;
ws = [warning('off','MTEX:MLS:rangeTooFew'), warning('off','MTEX:MLS:smoothTooFew')];
assertAlmostEqual(F.eval(w),2,'S2FunMLS, degree zero, range search with empty neighborhoods')
warning(ws);

% vector valued, and the values of coinciding nodes combine directly
F = S2FunMLS(v,[p2(v),p3(v)],'degree',2,noReg{:});
assert(isequal(size(F.eval(w)),[numel(w) 2]),'S2FunMLS: vector valued eval')
G = F(1) .* F(1);
assert(isa(G,'S2FunMLS'),'S2FunMLS .* S2FunMLS on the same nodes is no S2FunMLS')
assertAlmostEqual(G.values,p2(v).^2,'S2FunMLS .* S2FunMLS')
assertAlmostEqual(max(F(1)),max(p2(v)),'max(S2FunMLS)')

% the default, regularized fit of a smooth function
F = S2FunMLS(v,exp(v.x));
assert(max(abs(F.eval(w) - exp(w.x))) < 1e-2,'S2FunMLS, default options')

end

% -------------------------------------------------------------------------
function checkSO3Reproduction
% every SO3 mode reproduces a polynomial of the ansatz space

ori = orientation.rand(1500);
w = orientation.rand(30);
q2 = @(o) o.a.^2 - o.b.*o.c + 0.3*o.d.^2 + o.a.*o.d;
% Voronoi volumes cost most of the construction and do not change a reproduction
noReg = {'regularize',false,'use_smooth_delta',false,'use_vor_weights',false};

F = SO3FunMLS(ori,q2(ori),'degree',2,noReg{:});
assertAlmostEqual(F.eval(w),q2(w),'SO3FunMLS, centered monomials')
assert(F.dim == 10,'SO3FunMLS: wrong ansatz dimension')

F = SO3FunMLS(ori,q2(ori),'degree',2,'centered',false,noReg{:});
assertAlmostEqual(F.eval(w),q2(w),'SO3FunMLS, global monomials')

F = SO3FunMLS(ori,q2(ori),'degree',2,'regularize',false,'use_vor_weights',false);
assertAlmostEqual(F.eval(w),q2(w),'SO3FunMLS, smooth support radius')

F.delta = F.compute_delta;
assertAlmostEqual(F.eval(w),q2(w),'SO3FunMLS, range search')

F = SO3FunMLS(ori,2*ones(size(ori)),'degree',0,'use_vor_weights',false);
assertAlmostEqual(F.eval(w),2,'SO3FunMLS, degree zero')

% the default, regularized fit of a smooth function
ori = ori(1:600);
F = SO3FunMLS(ori,q2(ori));
assert(max(abs(F.eval(w) - q2(w))) < 1e-2,'SO3FunMLS, default options')
assert(F.dim == 35,'SO3FunMLS: wrong ansatz dimension')

end

% -------------------------------------------------------------------------
function checkOddDegree
% an odd degree is always evaluated in centered coordinates
%
% Unit quaternions q and -q are the same rotation, and an odd polynomial
% changes sign between them. Only centered coordinates fix the sign of the
% neighbors relative to the center.

ori = orientation.rand(1500);
w = orientation.rand(30);
q2 = @(o) o.a.^2 - o.b.*o.c + 0.3*o.d.^2 + o.a.*o.d;

opt = {'centered',false,'regularize',false,'use_smooth_delta',false,'use_vor_weights',false};

F = SO3FunMLS(ori,q2(ori),'degree',3,opt{:});
assert(F.centered,'SO3FunMLS: an odd degree has to switch to centered coordinates')
assert(max(abs(F.eval(w) - q2(w))) < 5e-2,'SO3FunMLS: odd degree fit is off')

F = SO3FunMLS(ori,q2(ori),'degree',2,opt{:});
F.degree = 3;
assert(F.centered,'SO3FunMLS: setting an odd degree has to switch to centered coordinates')

end

% -------------------------------------------------------------------------
function checkConstruction
% construction routes besides nodes and values

% from a function handle
F = S2FunMLS.approximate(@(x) x.z,'resolution',10*degree);
w = vector3d.rand(20);
assert(max(abs(F.eval(w) - w.z)) < 1e-2,'S2FunMLS.approximate is off')

% concatenation with a function of another class
v = vector3d.rand(300);
G = [S2FunMLS(v,v.x,'degree',1,'regularize',false); S2FunHandle(@(x) x.y)];
assertAlmostEqual(G.eval(w),[w.x,w.y],'[S2FunMLS; S2FunHandle] is wrong')

% a symmetry passed like to every other SO3Fun constructor
cs = crystalSymmetry('432');
F = SO3FunMLS(orientation.rand(500),rand(500,1),cs,'degree',2, ...
  'regularize',false,'use_smooth_delta',false,'use_vor_weights',false);
assert(F.CS == cs,'SO3FunMLS ignores a crystal symmetry passed positionally')

end

% -------------------------------------------------------------------------
function checkAntipodalSearch
% antipodal nodes given on one hemisphere are found from the other one

v = vector3d.rand(2000); v = v(v.z > 0);
v.antipodal = true;
F = S2FunMLS(v,v.z.^2,'degree',2,'regularize',false,'use_smooth_delta',false);

w = vector3d.rand(20); w = w(w.z < 0);
[~,d] = F.nodes.find(w,5);
dRef = sort(angle(w(:),v(:).'),2);
assertAlmostEqual(d,dRef(:,1:5),'antipodal neighbors from the other hemisphere')

end

% -------------------------------------------------------------------------
function checkAntipodalMisorientation
% misorientations with grain exchange symmetry, m and inv(m) are one point

cs = crystalSymmetry('222');
f = SO3FunRBF(orientation.id(cs,cs),SO3DeLaValleePoussinKernel('halfwidth',45*degree));
ori = orientation.rand(1500,cs,cs);
w = orientation.rand(30,cs,cs);
opt = {'degree',2,'regularize',false,'use_smooth_delta',false,'use_vor_weights',false};
err = max(abs(SO3FunMLS(ori,f.eval(ori),opt{:}).eval(w) - f.eval(w)));

ori.antipodal = true;
w.antipodal = true;
errAntipodal = max(abs(SO3FunMLS(ori,f.eval(ori),opt{:}).eval(w) - f.eval(w)));
assert(errAntipodal < 2 * err, ...
  'check_MLSFun: antipodal misorientations are off by %g, %g without the flag',errAntipodal,err)

end

% -------------------------------------------------------------------------
function checkVariableSizeSolver
% neighborhoods of strongly varying size are solved in groups of similar size,
% and a group may hold a single neighborhood

sizes = [12;40];
G = rand(sum(sizes),3);
c = solve_lsq_book_varsize(ones(sum(sizes),1),G,G*[1;2;3],sizes);
assertAlmostEqual(c,repmat([1;2;3],[1 1 2]),'solve_lsq_book_varsize, one neighborhood per group')

end

% -------------------------------------------------------------------------
function assertAlmostEqual(a,b,msg)

if max(abs(a(:)-b(:))) > 1e-8, error('check_MLSFun:failed','check_MLSFun: %s',msg); end

end
