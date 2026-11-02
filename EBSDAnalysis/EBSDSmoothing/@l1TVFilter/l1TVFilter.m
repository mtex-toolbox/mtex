classdef l1TVFilter < EBSDFilter
  % total variation denoising of orientation maps
  %
  % The filter minimises the distance to the measured orientations plus
  % alpha times the total variation, the sum of the misorientations between
  % neighbouring pixels. The absolute values keep sharp steps, so a subgrain
  % boundary survives the smoothing instead of being blurred away. The
  % default method is half-quadratic minimisation on manifolds:
  % R. Bergmann, R. H. Chan, R. Hielscher, J. Persch, G. Steidl,
  % Restoration of Manifold-Valued Images by Half-Quadratic Minimization,
  % Inverse Problems and Imaging 10 (2016). The method 'proximal' is a
  % cyclic proximal point algorithm for the same functional; it ignores the
  % threshold and the quality of the pixels.
  %
  % The half-quadratic method works on the tangent vectors of every pixel at
  % the mean orientation of its grain and solves each reweighted least
  % squares problem by conjugate gradients, for all grains of a map at once
  % in batches of whole grains of at most batchSize pixels. The iteration is
  % accelerated by Anderson extrapolation over its last five steps, and a
  % grain stops once none of its measured pixels moves by more than tol.
  %
  % Syntax
  %   F = l1TVFilter
  %   F = l1TVFilter(smoothingLength)
  %   F.method = 'proximal';
  %   ebsd = smooth(ebsd,F)
  %
  % Input
  %  smoothingLength - the wavelength damped to half its amplitude, in the
  %  units of the map; four pixel distances when empty
  %
  % Class Properties
  %  smoothingLength - the wavelength damped to half its amplitude
  %  alpha     - regularization parameter, larger means smoother; empty
  %              means the one of the smoothing length
  %  method    - 'halfQuadratic' or 'proximal'
  %  l1DataFit - use the l1 norm for data fitting, else the l2 norm
  %  l1TV      - use the l1 norm for regularization, else the l2 norm
  %  iterMax   - maximum number of iterations
  %  tol       - stopping criterion of the half-quadratic iteration
  %  eps       - l1 relaxation parameter
  %  threshold - threshold for subgrain boundaries
  %  lambda    - step sizes of the proximal point iteration
  %  batchSize - number of pixels whose grains are solved together
  %  isHex     - is the map on a hexagonal grid
  %
  % See also
  % EBSDFilter EBSD/smooth splineFilter infimalConvolutionFilter
  %

  properties
    smoothingLength = []  % wavelength damped to half, in map units
    alpha = [];           % regularization parameter
    method = 'halfQuadratic' % or 'proximal'
    l1DataFit = true      % use l^1 norm for data fitting
    l1TV      = true      % use l^1 norm for regularization
    iterMax   = 1000;     % maximum number of iterations
    tol   = 0.001*degree  % stopping criteria for the gradient descent
    eps   = 1e-3;         % l^1 relaxation parameter
    threshold = 15*degree % threshold for subgrain boundaries
    lambda = 2.8*(1:10000).^(-1.2) % step sizes of the proximal point iteration
    batchSize = 1e6       % pixels whose grains are solved together
  end

  methods

    function F = l1TVFilter(smoothingLength)
      if nargin > 0, F.smoothingLength = smoothingLength; end
    end

    function ori = smooth(F,ori,quality)

      if nargin == 2, quality = ones(size(ori)); end
      quality = quality ./ max(quality(:));

      % project around center, past this the neighbours need no symmetry
      [m,ori] = mean(ori);
      q = cat(4,ori.a,ori.b,ori.c,ori.d);

      if strcmpi(F.method,'proximal')
        u = proximal(F,q,regularization(F));
        u = reshape(u,[],4);
      else
        % one grain, the tangent vectors of its pixels at the mean
        ref = repmat([m.a m.b m.c m.d],numel(ori),1);
        f = logRight(reshape(q,[],4),ref);
        in = ~isnan(f(:,1));
        [a,b] = gridEdges(F.isHex,size(ori),double(in));
        loc = cumsum(in);
        u = nan(numel(in),4);
        u(in,:) = expRight(irls(F,f(in,:),quality(in),loc(a),loc(b),ones(nnz(in),1),regularization(F)),ref(in,:));
      end

      ori.a = reshape(u(:,1),size(ori));
      ori.b = reshape(u(:,2),size(ori));
      ori.c = reshape(u(:,3),size(ori));
      ori.d = reshape(u(:,4),size(ori));
    end

    function rot = smoothMap(F,ebsd,grainId)
      % all grains of a gridded map, in batches of whole grains

      rot = ebsd.rotations;
      comp = reshape(grainId,[],1);
      comp(isnan(comp)) = 0;
      [ref,f] = tangentField(ebsd,comp);
      comp(isnan(ref(:,1))) = 0;

      w = reshape(ebsd.prop.quality,[],1);
      w = w ./ max(w); w(isnan(f(:,1))) = 0;
      [a,b] = gridEdges(F.isHex,size(ebsd),comp);

      % whole grains up to batchSize pixels per batch
      [~,~,g] = unique(comp(comp>0));
      nPx = accumarray(g,1);
      batchOfGrain = 1 + floor((cumsum(nPx) - nPx) / F.batchSize);
      batch = zeros(size(comp)); batch(comp>0) = batchOfGrain(g);

      alpha = regularization(F);
      loc = zeros(size(comp));
      % the progress is the share of grains that have converged
      pC = progressCounter(numel(nPx),'caption',' denoising EBSD data: ');
      done = 0;
      for k = 1:max(batch)
        pix = find(batch == k);
        loc(pix) = 1:numel(pix);
        e = batch(a) == k;
        [~,~,c] = unique(comp(pix));
        u = expRight(irls(F,f(pix,:),w(pix),loc(a(e)),loc(b(e)),c,alpha,@(n) pC.show(done + n)),ref(pix,:));
        rot.a(pix) = u(:,1); rot.b(pix) = u(:,2); rot.c(pix) = u(:,3); rot.d(pix) = u(:,4);
        done = done + max(c);
      end
    end

  end

  methods (Access = private)

    function alpha = regularization(F)
      % the gain 1/(1+alpha*lambda) is one half at the smoothing length, lambda the
      % eigenvalue of the grid's Laplacian at that wavelength
      alpha = F.alpha;
      if isempty(alpha)
        L = F.smoothingLength;
        if isempty(L), L = 4*F.dx; end
        alpha = 1 / graphEigenvalue(F.isHex, max(L/F.dx,2));
      end
    end

    function u = proximal(F,q,alpha)

      if ~F.l1DataFit || ~F.l1TV
        error('The proximal method minimises the l1 data fit and the l1 total variation only.');
      end

      % the cyclic proximal point iteration on n x m x 4 unit quaternions, the
      % pixels without a measurement started at the mean
      qIn = reshape(q,[size(q,[1 2]) 4]);
      isOut = isnan(qIn(:,:,1));
      m = mean(reshape(qIn(~isOut(:,:,[1 1 1 1])),[],4),1);
      u = qIn;
      u(isOut(:,:,[1 1 1 1])) = repmat(m ./ norm(m),nnz(isOut),1);

      for k = 1:F.iterMax
        if F.isHex
          u = proxTVhex(u, F.lambda(k), alpha);
        else
          u = proxTVSquare(u, F.lambda(k), alpha);
        end
        u = proxl1(u, qIn, F.lambda(k));
      end
      u = reshape(u,[size(u,[1 2]) 1 4]);
    end


  end

end


% the reweighted least squares of the half-quadratic model: tangent vectors f, data
% weights w, zero without a measurement, and the edges a-b inside the components comp,
% each of which stops once none of its pixels moves by tol; report gets the number of
% components stopped
function x = irls(F,f,w,a,b,comp,alpha,report)

f(w == 0,:) = 0;
x = f;
active = true(max([comp;0]),1);
loc = zeros(numel(comp),1);
m = 0; p = [];

% the Anderson history, updated step by step: the differences of the iterates
% and of their steps in a ring of M columns over the moving pixels, the Gram
% matrix of the step differences, and the last iterate and step
M = 4; dY = []; dG = []; gram = zeros(M); yL = []; gL = []; cnt = 0; head = 1;

for iter = 1:F.iterMax

  % the pixels and the edge differences D of the components still moving
  pOld = p;
  p = find(active(comp));
  if numel(p) ~= m
    m = numel(p);
    loc(p) = 1:m;
    e = active(comp(a));
    ea = loc(a(e)); eb = loc(b(e));
    ne = numel(ea);
    D = sparse([1:ne,1:ne],[ea;eb],[ones(ne,1);-ones(ne,1)],ne,m);
    Dt = D';
    % the stopped pixels leave the history, the others keep theirs
    if ~isempty(yL)
      keep = repmat(ismember(pOld,p),3,1);
      yL = yL(keep); gL = gL(keep);
      if ~isempty(dY), dY = dY(keep,:); dG = dG(keep,:); end
      gram(1:cnt,1:cnt) = dG(:,1:cnt)' * dG(:,1:cnt);
    end
  end
  xp = x(p,:); fp = f(p,:); wp = w(p);

  t = sqrt(sum((D*xp).^2,2));
  if F.l1TV, wr = alpha * (t <= F.threshold) ./ sqrt(t.^2+F.eps^2); else, wr = alpha * ones(size(t)); end
  if F.l1DataFit, wd = wp ./ sqrt(sum((xp-fp).^2,2)+F.eps^2); else, wd = wp; end

  % a pixel without any weight keeps its value
  A = Dt * spdiags(wr,0,ne,ne) * D + spdiags(wd,0,m,m);
  dA = full(diag(A));
  s = dA > 0;
  y = xp;
  % the preconditioner shifted slightly, since a block without data is singular
  L = ichol(A(s,s) + 1e-9 * max(dA) * speye(nnz(s)));
  y(s,:) = cg(A(s,s),wd(s).*fp(s,:),xp(s,:),L);
  if ~F.l1DataFit && ~F.l1TV, x(p,:) = y; break; end

  % Anderson extrapolation from the last five steps, taken in the components whose
  % energy it lowers; the new differences overwrite the oldest column, and the
  % Gram matrix gets their column
  g = y(:) - xp(:);
  xn = y;
  if ~isempty(yL)
    if isempty(dY), dY = zeros(numel(g),M); dG = zeros(numel(g),M); end
    dY(:,head) = y(:) - yL; dG(:,head) = g - gL;
    cnt = min(cnt + 1,M);
    if cnt == M, dGk = dG; dYk = dY; else, dGk = dG(:,1:cnt); dYk = dY(:,1:cnt); end
    gram(1:cnt,head) = dGk' * dG(:,head); gram(head,1:cnt) = gram(1:cnt,head)';
    head = mod(head,M) + 1;
    xa = reshape(y(:) - dYk * ((gram(1:cnt,1:cnt) + 1e-12*eye(cnt)) \ (dGk'*g)),size(y));
    better = energy(F,xa,fp,wp,D,ea,comp(p),alpha) < energy(F,y,fp,wp,D,ea,comp(p),alpha);
    xn(better(comp(p)),:) = xa(better(comp(p)),:);
    if ~any(better), cnt = 0; head = 1; end
  end
  yL = y(:); gL = g;
  x(p,:) = xn;

  % a component stops once the reweighting moves none of its pixels by tol
  step = accumarray(comp(p),max(abs(y - xp),[],2),size(active),@max);
  active = active & step >= F.tol;
  if nargin > 7, report(nnz(~active)); end
  if ~any(active), break; end
end

end


% the functional the reweighting minimises per component, the differences above the
% threshold capped; ea the first pixel of every edge
function J = energy(F,x,f,w,D,ea,comp,alpha)

t2 = sum((D*x).^2,2);
r2 = sum((x-f).^2,2);
if F.l1TV, jt = alpha * sqrt(min(t2,F.threshold^2) + F.eps^2); else, jt = alpha/2 * t2; end
if F.l1DataFit, jd = w .* sqrt(r2 + F.eps^2); else, jd = w .* r2/2; end
n = max(comp);
J = accumarray(comp(ea),jt,[n 1]) + accumarray(comp,jd,[n 1]);

end


% conjugate gradients with the preconditioner L*L' for all columns of B at once
function X = cg(A,B,X,L)

Lt = L';
nb = max(sqrt(sum(B.^2,1)),realmin);
R = B - A*X;
Z = Lt \ (L \ R);
P = Z;
rz = sum(R.*Z,1);
for k = 1:2000
  if all(sqrt(sum(R.^2,1)) <= 1e-7 * nb), break; end
  Q = A*P;
  al = rz ./ sum(P.*Q,1); al(rz == 0) = 0;
  X = X + al .* P;
  R = R - al .* Q;
  Z = Lt \ (L \ R);
  rzn = sum(R.*Z,1);
  be = rzn ./ rz; be(rz == 0) = 0;
  P = Z + be .* P;
  rz = rzn;
end

end


% every pixel with a measurement as tangent vector at the mean orientation of its
% component, ref the mean as n x 4 quaternion, NaN outside every component
function [ref,f] = tangentField(ebsd,comp)

n = numel(comp);
ref = nan(n,4); f = nan(n,3);
isData = comp > 0 & ~isnan(ebsd.rotations.a(:)) & ebsd.isIndexed(:);
refG = nan(max([comp;0]),4);
for p = unique(ebsd.phaseId(isData)).'
  sel = find(isData & ebsd.phaseId(:) == p);
  o = ebsd.subSet(sel).orientations;

  % the mean around the first pixel of every component
  [gu,first,g] = unique(comp(sel));
  o = project2FundamentalRegion(o,o(first(g)));
  Q = [o.a o.b o.c o.d];
  Q = Q .* sign(sum(Q .* Q(first(g),:),2));
  m = [accumarray(g,Q(:,1)),accumarray(g,Q(:,2)),accumarray(g,Q(:,3)),accumarray(g,Q(:,4))];
  m = m ./ sqrt(sum(m.^2,2));
  refG(gu,:) = m;

  o = project2FundamentalRegion(o,quaternion(m(g,1),m(g,2),m(g,3),m(g,4)));
  f(sel,:) = logRight([o.a o.b o.c o.d],m(g,:));
end
in = comp > 0;
ref(in,:) = refG(comp(in),:);

end


% the neighbouring pixel pairs of a grid inside the same component
function [a,b] = gridEdges(isHex,sz,comp)

if isHex, id = hexNeighbors(sz); else, id = squareNeighbors(sz); end
a = repmat((1:prod(sz)).',size(id,3),1);
b = id(:);
keep = a < b & comp(a) > 0 & comp(a) == comp(b);
a = a(keep); b = b(keep);

end


% inv(r) .* p as rotation vectors, unit quaternions as rows
function v = logRight(p,r)

a = sum(r.*p,2);
v = r(:,1).*p(:,2:4) - p(:,1).*r(:,2:4) - cross(r(:,2:4),p(:,2:4),2);
s = sqrt(sum(v.^2,2));
omega = 2 * (1 - 2*(a < 0)) .* atan2(s,abs(a)) ./ s;
omega(s == 0) = 0;
v = omega .* v;

end


% r .* exp(v) for rotation vectors v as rows
function r = expRight(v,r)

omega = sqrt(sum(v.^2,2));
s = sin(omega/2) ./ omega;
s(omega == 0) = 0.5;
e = [cos(omega/2), s .* v];
r = [r(:,1).*e(:,1) - sum(r(:,2:4).*e(:,2:4),2), ...
  r(:,1).*e(:,2:4) + e(:,1).*r(:,2:4) + cross(r(:,2:4),e(:,2:4),2)];

end


% the eigenvalue of the grid's Laplacian at a plane wave of L pixel distances along the
% grid's first direction, summed over the neighbours of a pixel
function lambda = graphEigenvalue(isHex,L)

if isHex, p = [1 -1 0.5 -0.5 0.5 -0.5]; else, p = [1 -1 0 0]; end
lambda = sum(1 - cos(2*pi*p/L));

end
