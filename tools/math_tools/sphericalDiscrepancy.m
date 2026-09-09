function [res,info] = sphericalDiscrepancy(a,b,varargin)
% shared implementation of S2Fun/discrepancy and vector3d/discrepancy

metric = get_option(varargin,'metric','D_2');
assert(ischar(metric) || (isstring(metric) && isscalar(metric)), ...
  'S2Fun:discrepancy:metric','The metric must be D_cap, D_2, L2 or kernel.');
metric = lower(char(metric));
assert(any(strcmp(metric,{'d_cap','dcap','d_2','d2','l2','e_l'})), ...
  'S2Fun:discrepancy:metric','Unknown discrepancy metric: %s.',metric);
assert((isa(a,'S2Fun') || isa(a,'vector3d')) && ...
  (isa(b,'S2Fun') || isa(b,'vector3d')), ...
  'S2Fun:discrepancy:input','Inputs must be S2Fun or vector3d.');
bw = max(defaultBandwidth(a),defaultBandwidth(b));
if isa(a,'S2Fun') && isa(b,'vector3d'), bw = defaultBandwidth(a); end
if isa(b,'S2Fun') && isa(a,'vector3d'), bw = defaultBandwidth(b); end
bw = get_option(varargin,'bandwidth',bw);
assert(isnumeric(bw) && isscalar(bw) && isreal(bw) && isfinite(bw) && ...
  bw>=0 && bw==fix(bw),'S2Fun:discrepancy:bandwidth', ...
  'The bandwidth must be a nonnegative integer.');

mass = 1;
if isa(a,'S2Fun'), mass = functionMass(a); end
if isa(b,'S2Fun')
  massB = functionMass(b);
  if isa(a,'S2Fun')
    assert(abs(mass-massB)<=1e-10*max(abs([mass,massB])), ...
      'S2Fun:discrepancy:massMismatch','Functions must have equal integrals.');
  end
  mass = massB;
end

% Represent nu as a signed harmonic density plus signed atoms. Point sets
% retain their full measure for cap metrics, not a harmonic approximation.
[hA,xA,cA,exactA] = representation(a,bw,mass,'weights',varargin{:});
weightName = 'weights';
if isa(a,'vector3d') && isa(b,'vector3d'), weightName = 'weights2'; end
[hB,xB,cB,exactB] = representation(b,bw,mass,weightName,varargin{:});
fhat = hA-hB;
x = [xA;xB]; c = [cA;-cB];
info = struct('method','','isExact',exactA && exactB,'bandwidth',bw);

switch metric
  case {'d_cap','dcap'}
    [res,capInfo] = maximumCap(fhat,x,c,bw,varargin{:});
    info.method = 'finite center and height search';
    info.isExact = false;
    info.center = capInfo.center; info.height = capInfo.height;
    info.closed = capInfo.closed; info.signedDifference = capInfo.signedDifference;
    info.numCenters = capInfo.numCenters; info.numHeights = capInfo.numHeights;
    if check_option(varargin,'squared'), res = res^2; end
    return
  case {'d_2','d2'}
    % Stolarsky: D_2^2(nu) = -1/4 integral |x-y| dnu(x) dnu(y).
    % The atomic nonconstant energy includes its complete spectral tail.
    energy = sum(c)^2/3;
    for first = 1:512:numel(c)
      id = first:min(first+511,numel(c));
      distances = sqrt((x.x(id)-x.x.').^2 + (x.y(id)-x.y.').^2 + ...
        (x.z(id)-x.z.').^2);
      energy = energy - c(id).'*distances*c/4;
    end
    weights = zeros((bw+1)^2,1);
    for l = 1:bw
      weights(l^2+1:(l+1)^2) = 4*pi/((2*l-1)*(2*l+1)*(2*l+3));
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
      'S2Fun:discrepancy:degreeWeights', ...
      'degreeWeights must contain L+1 finite nonnegative energy weights.');
    energy = 0;
    for l = 1:bw
      energy = energy + degreeWeights(l+1)*sum(abs(difference(l^2+1:(l+1)^2)).^2);
    end
    info.method = 'weighted bandlimited harmonic norm';
end
res = max(0,real(energy));
if ~check_option(varargin,'squared'), res = sqrt(res); end
end

function bw = defaultBandwidth(a)
if isa(a,'S2FunHarmonic'), bw = a.bandwidth; else, bw = 128; end
end

function mass = functionMass(f)
assert(isscalar(f),'S2Fun:discrepancy:scalarFunction', ...
  'Discrepancy requires scalar spherical functions.');
mass = sum(f);
assert(isreal(mass) && isfinite(mass),'S2Fun:discrepancy:mass', ...
  'The function integral must be real and finite.');
end

function [h,x,c,exact] = representation(a,bw,mass,weightName,varargin)
h = zeros((bw+1)^2,1); x = vector3d; c = zeros(0,1);
if isa(a,'S2Fun')
  exact = isa(a,'S2FunHarmonic') && a.bandwidth<=bw;
  f = S2FunHarmonic(a,'bandwidth',bw); f.bandwidth = bw;
  assert(f.isReal,'S2Fun:discrepancy:realFunction','Functions must be real valued.');
  assert(all(isfinite(f.fhat)),'S2Fun:discrepancy:coefficients', ...
    'Harmonic coefficients must be finite.');
  h = f.fhat;
  h(1) = mass/sqrt(4*pi);
else
  exact = true;
  assert(numel(a)>0,'S2Fun:discrepancy:emptySample','Point sets must not be empty.');
  c = sampleWeights(numel(a),'weights', ...
    get_option(varargin,weightName,ones(numel(a),1)));
  assert(all(isfinite(c)) && sum(c)>0,'S2Fun:discrepancy:weights', ...
    'Point weights must be finite and have positive total weight.');
  assert(all(isfinite(a.x(:))) && all(isfinite(a.y(:))) && ...
    all(isfinite(a.z(:))) && all(norm(a(:))>0), ...
    'S2Fun:discrepancy:points','Points must have finite nonzero coordinates.');
  x = vector3d(normalize(a(:)));
  if a.antipodal
    x.antipodal = false;
    x = [x;-x]; c = [c;c]/2;
  end
  c = mass*c;
end
end

function h = atomicMoments(x,c,bw)
h = zeros((bw+1)^2,1);
if isempty(c), return; end
if bw>0
  f = S2FunHarmonic.adjointNFSFT(x,c,'bandwidth',bw); f.bandwidth = bw;
  h = f.fhat;
end
h(1) = sum(c)/sqrt(4*pi);
end

function [res,info] = maximumCap(fhat,x,c,bw,varargin)
last = find(fhat,1,'last');
if isempty(last), bw = 0; else, bw = min(bw,ceil(sqrt(last))-1); end
numCenters = get_option(varargin,'numCenters',2049);
numHeights = get_option(varargin,'numHeights',257);
assert(isnumeric(numCenters) && isscalar(numCenters) && isfinite(numCenters) && ...
  numCenters>=1 && numCenters==fix(numCenters) && ...
  isnumeric(numHeights) && isscalar(numHeights) && isfinite(numHeights) && ...
  numHeights>=2 && numHeights==fix(numHeights), ...
  'S2Fun:discrepancy:capGrid','Use positive integer numCenters and numHeights >= 2.');
centers = get_option(varargin,'centers',[]);
if isempty(centers)
  centers = [vector3d(fibonacciS2Grid(numCenters));vector3d.X;vector3d.Y;vector3d.Z; ...
    -vector3d.X;-vector3d.Y;-vector3d.Z;x;-x];
end
assert(isa(centers,'vector3d') && numel(centers)>0 && ...
  all(isfinite(centers.x(:))) && all(isfinite(centers.y(:))) && ...
  all(isfinite(centers.z(:))) && all(norm(centers(:))>0), ...
  'S2Fun:discrepancy:capGrid','centers must be finite nonzero vector3d directions.');
centers = normalize(centers(:)); centers.antipodal = false;
% Each degree is evaluated once for all centers. Funk-Hecke then gives
% integral_cap f = 2*pi sum_l f_l(m) integral_t^1 P_l(s) ds.
values = zeros(numel(centers),bw+1);
values(:,1) = real(fhat(1))/sqrt(4*pi);
for l = 1:bw
  ids = l^2+1:(l+1)^2;
  if any(fhat(ids))
    h = zeros((l+1)^2,1); h(ids) = fhat(ids);
    f = S2FunHarmonic(h);
    values(:,l+1) = real(f.eval(centers));
  end
end
res = 0;
info = struct('center',centers(1),'height',1,'closed',true, ...
  'signedDifference',0,'numCenters',numel(centers),'numHeights',numHeights);
grid = linspace(-1,1,numHeights).';
for j = 1:numel(centers)
  q = max(-1,min(1,dot(x,centers(j))));
  t = unique([grid;q]);
  jump = zeros(size(t));
  if ~isempty(c)
    [~,idx] = ismember(q,t);
    jump = accumarray(idx,c,[numel(t),1]);
  end
  closed = flipud(cumsum(flipud(jump)));
  continuous = 2*pi*values(j,1)*(1-t);
  previous = ones(size(t)); current = t;
  for l = 1:bw
    next = ((2*l+1)*t.*current-l*previous)/(l+1);
    continuous = continuous + 2*pi*values(j,l+1)*(previous-next)/(2*l+1);
    previous = current; current = next;
  end
  differences = [continuous+closed,continuous+closed-jump];
  [value,idx] = max(abs(differences(:)));
  if value>res
    res = value;
    [row,col] = ind2sub(size(differences),idx);
    info.center = centers(j); info.height = t(row); info.closed = col==1;
    info.signedDifference = differences(idx);
  end
end
end
