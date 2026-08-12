function check_mex(varargin)
% verify the mex binaries, downloading the ones that are missing
%
% Syntax
%   check_mex
%   check_mex('fast')   % return at once if the binaries are already there
%   check_mex('strict') % raise if any check failed, instead of printing
%
% Description
% The release zip ships no binaries (see makeRelease.m), so on a fresh
% install this is what fetches them. They are downloaded one by one rather
% than as an archive: an archive full of unsigned native libraries is what
% Windows virus scanners object to most.
%
% The list is derived from mex_install rather than written out here, so that
% adding a mex cannot leave this behind - which it had, by five files.
%
% See also
% mex_install check_mexComplete

% every mex MTEX compiles itself ...
src = mex_install('list');
mexFiles = strings(1,numel(src));
for k = 1:numel(src)
  [~,name] = fileparts(src{k});
  mexFiles(k) = name;
end

% ... plus the NFFT family, which is vendored precompiled and so is not in
% mex_install's list, but still has to be present at runtime
mexFiles = [mexFiles, "nfftmex", "fptmex", "nfsftmex", "nfsoftmex"];

fName = fullfile(mtex_path, "mex",mexFiles{1} + "." + mexext);
if check_option(varargin,'fast') && exist(fName,'file'), return, end

% functional tests are optional - a file without one is only checked for
% being loadable
checks = localCheckMap;

res = false(size(mexFiles));

wraptext([newline 'Mex files are compiled binaries that are used ' ...
  'within MTEX to speed up time critical computations. ' ...
  'As mex files are specific to different operating systems it is ' ...
  'not so easy for us to provide working binaries for different types ' ...
  'of systems.']);

% disp([newline 'I''m now going to check all the mex files in' newline ...
%   newline '  ' fullfile(mtex_path,'mex') newline newline ...
%   'In case some of the mex files are not working, you have two options' newline ...
%   ' 1. Use the command ' ...
%   '<a href="matlab: mex_install(''force'')">mex_install</a> ' ...
%   'to compile the mex files yourself' newline ...
%   '    On a Mac this requires that you install XCode first.' newline ...  
%   ' 2. Switch to a slower Matlab based implementation.' newline ...
%   ]);

isMissing = false;
err = cell(length(mexFiles),1);
for k = 1:length(mexFiles)

  mexFile = mexFiles(k);
 
  fprintf(" checking: " + mexFile + "." + mexext);
  fName = fullfile(mtex_path, "mex",mexFile + "." + mexext);

  if ~exist(fName,'file')

    fprintf(2," <strong>missing</strong>" + newline);

    if downloadMex(mexFile,fName)
      fprintf(" checking: " + mexFile + "." + mexext);
    else
      fprintf(2," <strong>download failed</strong>" + newline);
      isMissing = true;
      continue
    end
  end

  try
    if isKey(checks,char(mexFile))
      fcn = checks(char(mexFile));
      res(k) = fcn();
    else
      % no functional test for this one - at least insist that MATLAB
      % recognizes the file as a mex it can load
      res(k) = exist(mexFile,'file') == 3;
    end
  catch e
    err{k} = e;
  end
  if res(k)
    fprintf(" <strong>ok</strong>" + newline);
  else
    fprintf(2," <strong>failed</strong>" + newline);
    if isempty(err{k})
      disp("  --> wrong result");
    else
      id = pushTemp(err{k});
      disp("  --> <a href=""matlab: rethrow(pullTemp(" + int2str(id) ...
        + "))"">" + err{k}.message + "</a>");
    end
  end
end

if isMissing
  wraptext(newline + "Some of the binaries are missing and could not be downloaded. The most likely " + ...
    "reason is that your antivirus program has prevented the download. " + ...
    "You have two options:" + newline + newline + ...
    " (a) Download the binaries manualy from" + newline + newline + ...
    "<a href=""" + releasePage + """>" + releasePage + "</a>" + ...
   newline + newline + ...
   " and copy them to " + fullfile(mtex_path, "mex") + newline + newline + ...
   " (b) complile the binaries yourself using the command " + newline + newline + ...
   "  <a href=""matlab: mex_install('force')"">mex_install('force')</a>" + ...
   newline);
  
  if ismac
    disp("On a Mac this requires to install XCode first!" + newline)
  elseif ispc
    wraptext("This requires that you have installed: MATLAB Support for MinGW-w64 C/C++ Compiler," + ...
      "which is an official and simple to install Matlab Addon" + newline);
  end

elseif all(res)

  disp(newline + "check succesful!" + newline)

else

  wraptext("Not all mex files are running. You might want to call" + ...
    newline + newline +...
    "  <a href=""matlab: mex_install('force')"">mex_install('force')</a>" ...
    + newline + newline + ...
    "to compile the mex files yourself.");
  if ismac
    disp("On a Mac this requires to install XCode first!" + newline)
  elseif ispc
    wraptext("This requires that you have installed: MATLAB Support for MinGW-w64 C/C++ Compiler," + ...
      "which is an official and simple to install Matlab Addon" + newline);
  end

end

% with 'strict' the verdict is raised rather than only printed, which is what
% lets a test suite gate on it - see check_mexFunctions. Without it the
% behaviour is unchanged, so startup_mtex's check_mex('fast') is unaffected.
if check_option(varargin,'strict')
  bad = cellstr(mexFiles(~res));
  if isMissing || ~isempty(bad)
    error('check_mex:failed','%d of %d mex checks failed: %s', ...
      numel(bad), numel(mexFiles), strjoin(bad,', '));
  end
end

end

% ===========================================================================
function url = releasePage
% where a user is sent to fetch the binaries by hand

url = "https://github.com/mtex-toolbox/mtex/releases/tag/" + releaseTag;

end

% ===========================================================================
function tag = releaseTag
% the release this MTEX was cut from
%
% VERSION holds the tag verbatim (makeRelease.m writes it there), so no
% translation is needed. A working copy that is not a release falls through
% to the 'latest' URLs below.

tag = string(getMTEXpref('version',''));
if strlength(tag) == 0 || ~startsWith(tag,'mtex-'), tag = "latest"; end

end

% ===========================================================================
function ok = downloadMex(mexFile,fName)
% fetch one binary from GitHub
%
% Individual files, never an archive: an archive full of unsigned native
% libraries is what Windows virus scanners object to most, and a single
% blocked archive would take every binary down with it.
%
% Release assets are used rather than the raw file in the repository,
% because a release asset is version matched - the raw URL always serves
% whatever develop happens to hold, which need not match the installed MTEX
% at all. The raw URL is kept as a last resort so that a working copy of
% develop still finds its binaries.

name = mexFile + "." + mexext;
tag  = releaseTag;

urls = "https://github.com/mtex-toolbox/mtex/releases/download/" + tag + "/" + name;
if tag ~= "latest"
  urls(end+1) = "https://github.com/mtex-toolbox/mtex/releases/latest/download/" + name;
end
urls(end+1) = "https://raw.githubusercontent.com/mtex-toolbox/mtex/develop/mex/" + name;

ok = false;
for url = urls

  try
    disp("  downloading from  <a href=""" + url + """>" + url + "</a>")
    disp("  and saving it to " + fName);

    websave(fName,url);
    ok = true;
    return

  catch
    % a release may legitimately carry no asset for this platform - try the
    % next source rather than giving up on the file
  end
end

end

% ===========================================================================
function map = localCheckMap
% name -> functional test, for those files that have one
%
% Built from the local functions actually present, so that adding a
% check_<mexFile> below is all it takes to have it run, and a file without
% one does not error.

fcns = localfunctions;
map  = containers.Map('KeyType','char','ValueType','any');

for k = 1:numel(fcns)
  name = func2str(fcns{k});
  if startsWith(name,'check_')
    map(name(7:end)) = fcns{k};
  end
end

end

% ===========================================================================
function out = check_insidepoly_dblengine

% a non convex star, so that a naive convex test would fail, and enough
% points that the comparison means something
[poly,x,y] = insidepolyCase;

out = all(logical(insidepoly(x,y,poly(:,1),poly(:,2))) == ...
  inpolygon(x,y,poly(:,1),poly(:,2)));

end

function out = check_insidepoly_sglengine

[poly,x,y] = insidepolyCase;

ref = inpolygon(x,y,poly(:,1),poly(:,2));
got = insidepoly(single(x),single(y),single(poly(:,1)),single(poly(:,2)));

% a point within a whisker of an edge may legitimately fall the other way in
% single precision, so those are excluded rather than demanded
safe = pointToPolyDistance(x,y,poly) > 1e-4;

out = all(logical(got(safe)) == ref(safe));

end

function [poly,x,y] = insidepolyCase
% one non convex polygon and one point cloud, shared by both engines

rng(0)
t = linspace(0,2*pi,13).';
poly = [cos(t).*(1+0.5*cos(5*t)), sin(t).*(1+0.5*cos(5*t))];

x = rand(2000,1)*4 - 2;
y = rand(2000,1)*4 - 2;

end

function d = pointToPolyDistance(x,y,poly)
% shortest distance from each point to the polygon outline

P1 = poly(1:end-1,:);
P2 = poly(2:end,:);

d = inf(numel(x),1);
for k = 1:size(P1,1)
  a = P1(k,:); b = P2(k,:);
  ab = b - a;
  t = max(0,min(1, ((x-a(1))*ab(1) + (y-a(2))*ab(2)) / (ab*ab.') ));
  d = min(d, hypot(x - (a(1)+t*ab(1)), y - (a(2)+t*ab(2))));
end

end


function out = check_jcvoronoi_mex %#ok<*DEFNU>

out = 1;

xy = rand(10,2);

[Vx,Vy,E1,E2,I_ED1,I_ED2] = jcvoronoi_mex(xy); %#ok<*ASGLU>


end

function out = check_EulerCyclesC

ebsd = mtexdata('small','silent');
grains = calcGrains(ebsd('indexed')); %#ok<*NASGU>

gB = grains.boundary;
nV = length(gB.allV);

[g, c, cP] = EulerCyclesC(gB.I_FG,gB.F,nV);

% g and c are offset arrays into c and cP - a nested CSR - so they have to
% close on the arrays they index, be monotone, and every cycle has to be a
% closed walk over vertices that exist
out = c(end) == numel(cP)+1 && g(end) == numel(c) && ...
  all(diff(g) >= 0) && all(diff(c) >= 0) && ...
  all(cP >= 1 & cP <= nV) && numel(c) > 1;

for k = 1:numel(c)-1
  idx = c(k):c(k+1)-1;
  out = out && numel(idx) >= 4 && cP(idx(1)) == cP(idx(end));
end

end

function out = check_chainOrderC

% the compiled walk must agree with the MATLAB one, which is what makes the
% two interchangeable - see chainOrder
F = [1 2; 2 3; 3 4; 5 6; 6 7];

[c1,p1,e1] = chainOrder(F,7);
[c2,p2,e2] = chainOrder(F,7,'noMex');

out = isequal(c1,c2) && isequal(p1,p2) && isequal(e1,e2);

end

function out = check_jcvoronoi2_mex

% a unit square of sites framed by a ring of dummies
[X,Y] = meshgrid(1:4,1:4);
[Xd,Yd] = meshgrid(0:5,0:5);
isReal = Xd(:)>=1 & Xd(:)<=4 & Yd(:)>=1 & Yd(:)<=4;
XY = [[X(:) Y(:)]; [Xd(~isReal) Yd(~isReal)]];

[V,F,I_FD] = jcvoronoi2_mex(XY,16,0.01);

% every site must keep a cell, and every segment must have two endpoints
out = size(V,2) == 2 && size(F,2) == 2 && size(I_FD,2) == 16 && ...
  all(sum(I_FD,1) > 0) && all(F(:) >= 1 & F(:) <= size(V,1));

end

function out = check_jcvoronoiDelaunayOnly_mex

[X,Y] = meshgrid(1:4,1:4);
[Xd,Yd] = meshgrid(0:5,0:5);
isReal = Xd(:)>=1 & Xd(:)<=4 & Yd(:)>=1 & Yd(:)<=4;
XY = [[X(:) Y(:)]; [Xd(~isReal) Yd(~isReal)]];

I_fast = jcvoronoiDelaunayOnly_mex(XY,16,0.01);
[~,~,I_full] = jcvoronoi2_mex(XY,16,0.01);

% the fast path may add adjacencies but must never miss one - see
% check_jcvoronoiDelaunayOnly
A_fast = triu((I_fast.'*I_fast)==1,1);
A_full = triu((I_full.'*I_full)==1,1);

out = ~any(A_full(:) & ~A_fast(:));

end

function out = check_nfsftmex

S2F = S2Fun.smiley('exact');
S2FH = S2FunHarmonic(S2F,'nfsft');
S2G = equispacedS2Grid;
out = norm(S2F.eval(S2G) - S2FH.eval(S2G,'nfsft')) < 0.01;

end

function out = check_nfsoftmex

SO3F = unimodalODF(rotation.rand,'halfwidth',20*degree);
rot = SO3F.discreteSample(100000);
SO3F2 = calcDensity(rot,'halfwidth',5*degree,'nfsoft');
S3G = rotation.rand(10000);

out = norm(SO3F.eval(S3G) - SO3F2.evalNFSOFT(S3G)) ./ norm(SO3F.eval(S3G)) < 0.1;

end

function out = check_nfftmex

plan = nfft(1,32,100);
plan.f = rand(100,1);
plan.x = rand(100,1);
plan.nfft_adjoint;
delete(plan);
out = 1;
end

function out = check_fptmex
out = 1;
end


function out = check_wignerTrafomex

SO3F = SO3Fun.dubna;
SO3FH = SO3FunHarmonic(SO3F);
S3G = equispacedSO3Grid(SO3F.CS);
v1 = SO3F.eval(S3G);
v2 = SO3FH.eval(S3G);
out = norm(v1(:) - v2(:))/norm(v2(:)) < 0.01;

end

function out = check_wignerTrafoAdjointmex

S3F = @(rot) rot.angle;
S3FH = SO3FunHarmonic(S3F);
out = abs(norm(S3FH)-2.3)<1e-3;

end

function out = check_numericalSaddlepointWithDerivatives

out = 1;
S2F = S2FunBingham([-1 0 1]);

end

function out = check_S1Grid_find

pts = [1,2,3,4,9];
x = S1Grid(pts,0,10);
out = find(x,3.2) == 3;

% periodic: 0.1 is nearest to 9.8 only if the wrap is honoured
xp = S1Grid([pts 9.8],0,10,'periodic');
out = out && find(xp,0.1) == 6;

% and against brute force across the range
q = linspace(0.5,9.5,200);
for k = 1:numel(q)
  [~,ref] = min(abs(pts - q(k)));
  out = out && find(x,q(k)) == ref;
end

end

function out = check_S1Grid_find_region

% returns a sparse logical MASK over the grid points, not a list of indices
pts = [1,2,3,4,9];
x = S1Grid(pts,0,10);

% 2.6 rather than a round 2.5, where a grid point sits exactly on the radius
% and whether it counts is a strict/non strict question
eps1 = 2.6;
out = true;
q = linspace(0.5,9.5,40);
for k = 1:numel(q)
  ref = find(abs(pts - q(k)) < eps1);
  got = find(full(logical(find(x,q(k),eps1))));
  out = out && isequal(got(:).',ref(:).');
end

xp = S1Grid([pts 9.8],0,10,'periodic');
find(xp,4,5);

end


function out = check_S2Grid_find

x  = equispacedS2Grid('points',500);
xv = vector3d(x);
y  = vector3d.rand(40);

got = find(x,y);

% compared through the dot_outer matrix: angle() broadcasts a column against
% a column into an outer product, so the elementwise reading would silently
% become 40x40
D = dot_outer(xv,y);
best = max(D,[],1);
lin = sub2ind(size(D),double(got(:)).',1:numel(y));

% S2Grid_find is not exact - it searches the nearest ring of constant theta
% and then within it, and near a cell boundary settles on a neighbour: 4 of
% 200 queries on a 510 point grid, overshooting by at most 0.84 degree with a
% 9.0 degree spacing. A fifth of the spacing tolerates that and would still
% catch a binary returning the wrong point.
spacing = sqrt(4*pi/numel(xv));
extra = acos(min(1,D(lin))) - acos(min(1,best));

out = numel(got) == numel(y) && max(extra) < 0.2*spacing;

end

function out = check_S2Grid_find_region

x  = equispacedS2Grid('points',500);
xv = vector3d(x);
y  = vector3d.rand(20);

% like the S1 version this returns a sparse logical MASK over the grid
eps1 = 0.35;
out = true;
for k = 1:numel(y)

  got = find(full(logical(find(x,y(k),eps1))));
  d = angle(xv,y(k));

  % the boundary of the radius is a strict/non strict question, so only the
  % clearly inside and clearly outside points are demanded
  inside  = find(d < eps1 - 1e-6);
  outside = find(d > eps1 + 1e-6);

  out = out && ~isempty(inside) && all(ismember(inside,got)) && ...
    ~any(ismember(outside,got));
end

end

function out = check_SO3Grid_dist_region

cs = crystalSymmetry('432');
S3G = equispacedSO3Grid(cs,'resolution',2*degree);

ori = orientation.rand(cs);

d1 = angle_outer(S3G,ori,'epsilon',10*degree);
d2 = angle_outer(S3G,ori);

out = all(isnull(d2(d2< 5*degree) - d1(d2 < 5*degree)));

end

function out = check_SO3Grid_find_region

cs = crystalSymmetry('432');
S3G = equispacedSO3Grid(cs,'resolution',2*degree);

ori = orientation.rand(cs);

i = find(S3G,ori,10*degree);

d = angle(S3G,ori) < 10*degree;

out = all(d == i);

end

function out = check_SO3Grid_find

cs = crystalSymmetry('432');
S3G = equispacedSO3Grid(cs);

ori = orientation.byEuler(41*degree,31*degree,40*degree,cs);

i = find(S3G,ori);

d = angle(S3G,ori);

out = min(d(:))==d(i);

end

function out = check_SHTextractormex
out = 1;
end

function xxxx
cs = crystalSymmetry('trigonal');
ss = specimenSymmetry('1');

x = equispacedSO3Grid(cs,ss,'points',100000);
y = equispacedSO3Grid(cs,ss,'points',100000);


tic
dot_outer(x,y,'epsilon',5*degree);
toc

tic
find(x,quaternion(y),'epsilon',5*degree);
toc

find(x,quaternion.id,20*degree)

q = axis2quat(xvector+yvector,45*degree);
q = quaternion.id;

sx = quaternion(subGrid(x,find(x,q,10*degree)));

dist(cs,specimenSymmetry,q,sx) / degree


plot(inv(sx)*xvector)
plot(inv(sx)*yvector)
plot(inv(sx)*zvector)


A = cos(ay)*cos(cy)*cos(ax)*(cos(by)*cos(bx)-1) - ...
  sin(ay)*sin(cy)*cos(ax)*(cos(bx)-cos(by));

B = cos(ay)*cos(cy)*cos(ax)*(cos(by)*cos(bx)-1) - ...
  sin(ay)*sin(cy)*cos(ax)*(cos(bx)-cos(by));

end