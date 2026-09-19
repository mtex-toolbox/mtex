function [res,info] = rotationalDiscrepancy(a,b,varargin)
% shared implementation of SO3Fun/discrepancy and rotation/discrepancy

metric = get_option(varargin,'metric','D_2');
assert(ischar(metric) || (isstring(metric) && isscalar(metric)), ...
  'SO3Fun:discrepancy:metric','The metric must be D_ball, D_2, L2 or kernel.');
metric = lower(char(metric));
assert(any(strcmp(metric,{'d_ball','dball','d_2','d2','l2','e_l'})), ...
  'SO3Fun:discrepancy:metric','Unknown discrepancy metric: %s.',metric);
assert((isa(a,'SO3Fun') || isa(a,'rotation')) && ...
  (isa(b,'SO3Fun') || isa(b,'rotation')), ...
  'SO3Fun:discrepancy:input','Inputs must be SO3Fun or rotation.');
bw = max(defaultBandwidth(a),defaultBandwidth(b));
if isa(a,'SO3Fun') && isa(b,'rotation'), bw = defaultBandwidth(a); end
if isa(b,'SO3Fun') && isa(a,'rotation'), bw = defaultBandwidth(b); end
bw = get_option(varargin,'bandwidth',bw);
assert(isnumeric(bw) && isscalar(bw) && isreal(bw) && isfinite(bw) && ...
  bw>=0 && bw==fix(bw),'SO3Fun:discrepancy:bandwidth', ...
  'The bandwidth must be a nonnegative integer.');

% Each function keeps its own integral; an orientation set takes the one of
% the function it is compared with, and mass one against another set or a
% function that integrates to zero.
massA = []; massB = [];
if isa(a,'SO3Fun'), massA = functionMass(a); end
if isa(b,'SO3Fun'), massB = functionMass(b); end
if isempty(massA), massA = sampleMass(massB); end
if isempty(massB), massB = sampleMass(massA); end

% Represent nu as a signed harmonic density plus signed atoms. Orientation
% sets retain their full measure for ball metrics, not a harmonic approximation.
[hA,xA,cA,exactA] = representation(a,bw,massA,'weights',varargin{:});
weightName = 'weights';
if isa(a,'rotation') && isa(b,'rotation'), weightName = 'weights2'; end
[hB,xB,cB,exactB] = representation(b,bw,massB,weightName,varargin{:});
fhat = hA-hB;
x = [xA;xB]; c = [cA;-cB];
info = struct('method','','isExact',exactA && exactB,'bandwidth',bw);

switch metric
  case {'d_ball','dball'}
    [res,ballInfo] = maximumBall(fhat,x,c,bw,varargin{:});
    info.method = 'finite center and radius search';
    info.isExact = false;
    info.center = ballInfo.center; info.radius = ballInfo.radius;
    info.closed = ballInfo.closed; info.signedDifference = ballInfo.signedDifference;
    info.numCenters = ballInfo.numCenters; info.numRadii = ballInfo.numRadii;
    if check_option(varargin,'squared'), res = res^2; end
    return
  case {'d_2','d2'}
    % Stolarsky: D_2^2(nu) = nu(SO(3))^2/2
    %   - 1/(2*sqrt(2)*pi) integral |R-S|_F dnu(R) dnu(S), |R-S|_F =
    % sqrt(8) sin(omega/2). The chordal energy carries the mass with a
    % negative weight, the ball integral with a positive one, hence the two
    % constants below. The atomic nonconstant energy keeps its whole tail.
    energy = (4*pi^2-64/3)*abs(fhat(1)+sum(c)/sqrt(8*pi^2))^2 + ...
      8*sum(c)^2/(3*pi^2);
    q = [x.a(:) x.b(:) x.c(:) x.d(:)];
    for first = 1:512:numel(c)
      id = first:min(first+511,numel(c));
      % sin(omega/2) = |q-p| |q+p| / 2, from the quaternion coordinates
      minus = (q(id,1)-q(:,1).').^2 + (q(id,2)-q(:,2).').^2 + ...
        (q(id,3)-q(:,3).').^2 + (q(id,4)-q(:,4).').^2;
      plus = (q(id,1)+q(:,1).').^2 + (q(id,2)+q(:,2).').^2 + ...
        (q(id,3)+q(:,3).').^2 + (q(id,4)+q(:,4).').^2;
      energy = energy - c(id).'*sqrt(minus.*plus)*c/(2*pi);
    end
    weights = zeros(deg2dim(bw+1),1);
    for l = 1:bw
      weights(deg2dim(l)+1:deg2dim(l+1)) = 64/((2*l-1)*(2*l+1)^2*(2*l+3));
    end
    if any(fhat(2:end))
      moments = atomicMoments(x,c,bw);
      energy = energy + sum(weights.*(abs(fhat).^2 + ...
        2*real(conj(fhat).*moments)));
    end
    info.method = 'chordal atomic energy and harmonic continuous terms';
  otherwise
    moments = atomicMoments(x,c,bw);
    difference = fhat+moments;
    degreeWeights = get_option(varargin,'degreeWeights',ones(bw+1,1));
    if isa(degreeWeights,'function_handle'), degreeWeights = degreeWeights((0:bw).'); end
    assert(isnumeric(degreeWeights) && isreal(degreeWeights) && ...
      isvector(degreeWeights) && numel(degreeWeights)==bw+1 && ...
      all(isfinite(degreeWeights(:))) && all(degreeWeights(:)>=0), ...
      'SO3Fun:discrepancy:degreeWeights', ...
      'degreeWeights must contain L+1 finite nonnegative energy weights.');
    energy = degreeWeights(1)*abs(difference(1))^2;
    for l = 1:bw
      energy = energy + degreeWeights(l+1)* ...
        sum(abs(difference(deg2dim(l)+1:deg2dim(l+1))).^2);
    end
    info.method = 'weighted bandlimited harmonic norm';
end
res = max(0,real(energy));
if ~check_option(varargin,'squared'), res = sqrt(res); end
end

function bw = defaultBandwidth(a)
if isa(a,'SO3FunHarmonic'), bw = a.bandwidth; else, bw = 64; end
end

function mass = functionMass(f)
assert(isscalar(f),'SO3Fun:discrepancy:scalarFunction', ...
  'Discrepancy requires scalar rotational functions.');
mass = sum(f);
assert(isreal(mass) && isfinite(mass),'SO3Fun:discrepancy:mass', ...
  'The function integral must be real and finite.');
end

function mass = sampleMass(partner)
% a sample represents the function it is compared with, hence carries its
% integral - but a vanishing one represents nothing
if isempty(partner) || partner == 0, mass = 1; else, mass = partner; end
end

function [h,x,c,exact] = representation(a,bw,mass,weightName,varargin)
% Wigner coefficients refer to the basis that is orthonormal with respect to
% the Haar measure of total mass 8*pi^2, i.e. sqrt(8*pi^2) times the MTEX ones.
h = zeros(deg2dim(bw+1),1); x = rotation.id([]); c = zeros(0,1);
if isa(a,'SO3Fun')
  exact = isa(a,'SO3FunHarmonic') && a.bandwidth<=bw;
  f = SO3FunHarmonic(a,'bandwidth',bw); f.bandwidth = bw;
  assert(f.isReal,'SO3Fun:discrepancy:realFunction','Functions must be real valued.');
  assert(all(isfinite(f.fhat)),'SO3Fun:discrepancy:coefficients', ...
    'Wigner coefficients must be finite.');
  h = sqrt(8*pi^2)*f.fhat;
  h(1) = mass/sqrt(8*pi^2);
else
  exact = true;
  assert(numel(a)>0,'SO3Fun:discrepancy:emptySample','Orientation sets must not be empty.');
  c = sampleWeights(numel(a),'weights', ...
    get_option(varargin,weightName,ones(numel(a),1)));
  assert(all(isfinite(c)) && sum(c)>0,'SO3Fun:discrepancy:weights', ...
    'Point weights must be finite and have positive total weight.');
  assert(~any(a.i(:)),'SO3Fun:discrepancy:improper', ...
    'Improper rotations are not elements of SO(3).');
  % a symmetric orientation stands for the uniform measure on its orbit
  if isa(a,'orientation')
    s = symmetrise(a(:),'proper');
    x = normalize(rotation(s(:)));
    c = reshape(repmat(c(:).',size(s,1),1)/size(s,1),[],1);
  else
    x = normalize(rotation(a(:)));
  end
  c = mass*c;
end
end

function h = atomicMoments(x,c,bw)
h = zeros(deg2dim(bw+1),1);
if isempty(c), return; end
if bw>0
  f = SO3FunHarmonic.adjoint(x,c,'bandwidth',bw); f.bandwidth = bw;
  h = f.fhat/sqrt(8*pi^2);
end
h(1) = sum(c)/sqrt(8*pi^2);
end

function [res,info] = maximumBall(fhat,x,c,bw,varargin)
last = find(fhat,1,'last');
if isempty(last), bw = 0; else
  while bw>0 && deg2dim(bw)>=last, bw = bw-1; end
end
numCenters = get_option(varargin,'numCenters',2049);
numRadii = get_option(varargin,'numRadii',257);
assert(isnumeric(numCenters) && isscalar(numCenters) && isfinite(numCenters) && ...
  numCenters>=1 && numCenters==fix(numCenters) && ...
  isnumeric(numRadii) && isscalar(numRadii) && isfinite(numRadii) && ...
  numRadii>=2 && numRadii==fix(numRadii), ...
  'SO3Fun:discrepancy:ballGrid','Use positive integer numCenters and numRadii >= 2.');
centers = get_option(varargin,'centers',[]);
if isempty(centers)
  g = rotation(equispacedSO3Grid(crystalSymmetry('1'), ...
    specimenSymmetry('1'),'points',numCenters));
  centers = [g(:);rotation.id;x];
end
assert(isa(centers,'rotation') && numel(centers)>0 && ~any(centers.i(:)), ...
  'SO3Fun:discrepancy:ballGrid','centers must be proper rotations.');
centers = rotation(centers(:));
% Each degree is evaluated once for all centers. Funk-Hecke on SO(3) then
% gives integral_ball f = sqrt(8*pi^2) sum_l beta_l(r) f_l(C)/(2l+1).
values = zeros(numel(centers),bw+1);
values(:,1) = real(fhat(1));
for l = 1:bw
  ids = deg2dim(l)+1:deg2dim(l+1);
  if any(fhat(ids))
    h = zeros(deg2dim(l+1),1); h(ids) = fhat(ids);
    f = SO3FunHarmonic(h);
    values(:,l+1) = real(f.eval(centers));
  end
end
res = 0;
info = struct('center',centers(1),'radius',pi,'closed',true, ...
  'signedDifference',0,'numCenters',numel(centers),'numRadii',numRadii);
grid = linspace(0,pi,numRadii).';
for j = 1:numel(centers)
  q = angle(x,centers(j));
  t = unique([grid;q(:)]);
  jump = zeros(size(t));
  if ~isempty(c)
    [~,idx] = ismember(q(:),t);
    jump = accumarray(idx,c,[numel(t),1]);
  end
  closed = cumsum(jump);
  continuous = sqrt(8*pi^2)*values(j,1)*(t-sin(t))/pi;
  for l = 1:bw
    continuous = continuous + sqrt(8*pi^2)*values(j,l+1)/(2*l+1)* ...
      (sin(l*t)/l - sin((l+1)*t)/(l+1))/pi;
  end
  differences = [continuous+closed,continuous+closed-jump];
  [value,idx] = max(abs(differences(:)));
  if value>res
    res = value;
    [row,col] = ind2sub(size(differences),idx);
    info.center = centers(j); info.radius = t(row); info.closed = col==1;
    info.signedDifference = differences(idx);
  end
end
end
