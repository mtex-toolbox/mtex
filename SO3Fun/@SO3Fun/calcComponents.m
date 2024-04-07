function [modes, weights,centerId] = calcComponents(SO3F,varargin)
% heuristic to find modal orientations
%
% Syntax
%   [modes, volume] = calcComponents(SO3F)
%   [modes, volume, centerId] = calcComponents(SO3F,'seed',ori)
%
% Input
%  SO3F - @SO3Fun 
%  ori - initial list of @orientation
%
% Output
%  modes     - modal @orientation
%  volume    - volume of the component
%  centerId  - list of ids to which each initial ori converged to
%
% Options
%  resolution - search-grid resolution
%  angle      - maximum component width used for volume computation
%  exact      - do not dismiss very small modes at the end
%
% See also
% SO3Fun/max

% extract options
maxIter = get_option(varargin,'maxIter',100);
res = get_option(varargin,'resolution',0.05*degree);
omega = [0,3.3,5]*degree;
tol = get_option(varargin,'tolerance',1.5*degree);
maxAngle = get_option(varargin,{'radius','angle'},inf);

% initial seed
if check_option(varargin,'seed')
  seed = reshape(get_option(varargin,'seed'),[],1);
  weights = get_option(varargin,'weights',SO3F.eval(seed));
elseif isa(SO3F,'SO3FunRBF')
  seed = SO3F.center;
  weights = SO3F.weights; 
else
  seed = equispacedSO3Grid(SO3F.CS,SO3F.SS,'resolution',2.5*degree);
  weights = ones(length(seed),1) ./ length(seed);
end
id = weights>0;
seed = reshape(seed(id),[],1);
weights = weights(id);
weights = weights ./ sum(weights);

centerId = 1:length(seed);
modes = seed;
omega = repmat(omega,length(modes),1);

% join orientations if possible
%[modes,~,id2] = unique(modes,'tolerance',tol);
%centerId = id2(centerId);
%weights = accumarray(id2,weights);

G = SO3F.grad;

v_max = SO3F.eval(modes);

for k = 1:maxIter
  progress(k,maxIter,' finding ODF components: ',varargin{:});

  % gradient
  g = normalize(G.eval(modes),1);
  
  % prepare for linesearch
  line_ori = exp(repmat(modes,1,size(omega,2)),g .* omega);
  
  % evaluate along lines
  line_v = [v_max,SO3F.eval(line_ori(:,2:end))];
  
  % take the maximum
  [v_max,id] = max(line_v,[],2);
    
  % update orientions
  modes = line_ori(sub2ind(size(line_ori),(1:length(g)).',id));

  % update step size
  ind = id==1 & omega(:,1) > res;
  omega(ind,:) = omega(ind,:) ./ 2;
  
  %nnz(id>1)
  if all(id == 1), break; end

  % join orientations if possible
  [~,~,id2] = unique(modes,'tolerance',tol);

  ind = maxVote(id2,v_max);
  modes = modes(ind);
  omega = omega(ind,:);
  v_max = v_max(ind,:);

  centerId = id2(centerId);
  if maxAngle == inf, weights = accumarray(id2,weights); end

end

% accumulate only weights that are sufficiently close to the centers
if maxAngle < inf
  inRadius = angle(seed,modes(centerId))<maxAngle;
  weights = accumarray(centerId(inRadius), weights(inRadius));
end

% sort components according to volume
[weights,id] = sort(weights,'descend');
modes = modes(id);
iid(id) = 1:length(id);
centerId = iid(centerId);

if ~check_option(varargin,'exact')
  id = weights > min([0.01, numSym(SO3F.CS) * maxAngle^3 ./ 8*pi^2,0.5 * max(weights)]);  
  weights = weights(id);
  modes = modes(id);
  ids = 1:length(id);
  centerId(ismember(centerId,ids(~id))) = 0;
end
  
% weights = [2 1 5 3 4] -> [1 2 3 4 5]
% id -> [2 1 5 3 4]
% centerId = 3 -> 5 
end

function test
% testing code
 
cs = crystalSymmetry('432');
cs2 = specimenSymmetry;
center = orientation.rand(5,cs,cs2);
odf = unimodalODF(center,'halfwidth',5*degree) %#ok<NOPRT
ori = discreteSample(odf,2000);
odf2 = calcDensity(ori,'noFourier','exact','halfwidth',2.5*degree);
disp(odf2)


cs2 = crystalSymmetry('432');
center = orientation.rand(5,cs,cs2);
odf = unimodalODF(center,'halfwidth',2.5*degree);
ori = discreteSample(odf,1000);
odf2 = calcDensity(ori,'noFourier','exact','halfwidth',3*degree);
disp(odf2)

[modes,vol,cId] = odf2.calcComponents;

for i = 1:length(modes)
  plot(ori(cId==i),'axisAngle')
  hold on
  plot(modes(i),'MarkerFaceColor','k','MarkerSize',10)
end
hold off

min(angle_outer(modes,center) ./ degree)

end
