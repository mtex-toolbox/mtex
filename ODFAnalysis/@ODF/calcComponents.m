function [modes, weights,centerId] = calcComponents(odf,varargin)
% heuristic to find modal orientations
%
% Syntax
%   [modes, volume] = calcComponents(odf)
%   [modes, volume, centerId] = calcComponents(odf,'seed',ori)
%
% Input
%  odf - @ODF 
%  ori - initial list of @orientation
%
% Output
%  modes     - modal @orientation
%  volume    - volume of the component
%  centerId  - list of ids to which each initial ori converged to
%
% Options
%  resolution - search-grid resolution
%  exact      - do not dismiss very small modes at the end
%
% Example
%
%   %find the local maxima of the <SantaFe.html SantaFe> ODF
%   mode = calcModes(SantaFe)
%   plotPDF(SantaFe,Miller(0,0,1,mode.CS))
%   annotate(mode)
%
% See also
% ODF/max

maxIter = get_option(varargin,'maxIter',100);
res = get_option(varargin,'resolution',0.05*degree);
omega = 1.5.^(-7:1:4) * degree;
omega(omega<res) = [];
omega = [0,omega];
tol = get_option(varargin,'tolerance',0.05);

% initial seed
if check_option(varargin,'seed')
  modes = reshape(get_option(varargin,'seed'),[],1);
  weights = get_option(varargin,'weights',...
    odf.eval(modes));
elseif isa(odf.components{end},'unimodalComponent')
  modes = odf.components{end}.center;
  weights = odf.components{end}.weights;
else
  modes = equispacedSO3Grid(odf.CS,odf.SS,'resolution',5*degree);
  weights = ones(length(modes),1) ./ length(modes);
end
id = weights>0;
modes = reshape(modes(id),[],1);
weights = weights(id);
weights = weights ./ sum(weights);

centerId = 1:length(modes);

% join orientations if possible
[modes,~,id2] = unique(modes,'tolerance',tol);
centerId = id2(centerId);
weights = accumarray(id2,weights);

finished = false(size(modes));

for k = 1:maxIter
  progress(k,maxIter,' finding ODF components: ');

  % gradient
  g = normalize(odf.grad(modes(~finished)),1);

  % prepare for linesearch
  line_ori = exp(repmat(modes(~finished),1,length(omega)),g * omega);
  
  % evaluate along lines
  line_v = odf.eval(line_ori);
  
  % take the maximum
  [~,id] = max(line_v,[],2);
    
  % update orientions
  modes(~finished) = line_ori(sub2ind(size(line_ori),(1:length(g)).',id));
  
  finished(~finished) = id == 1;
  if all(finished), break; end

  % join orientations if possible
  [modes,~,id2] = unique(modes,'tolerance',tol);
  centerId = id2(centerId);
  
  weights = accumarray(id2,weights);
  finished = accumarray(id2,finished,[],@all);
  %[length(modes), k, sum(finished)]
end

% sort components according to volume
[weights,id] = sort(weights,'descend');
modes = modes(id);
iid(id) = 1:length(id);
centerId = iid(centerId);

if ~check_option(varargin,'exact')
  id = weights > 0.01;
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
odf = unimodalODF(center,'halfwidth',5*degree)
ori = odf.calcOrientations(2000);
odf2 = calcDensity(ori,'noFourier','exact','halfwidth',2.5*degree)


cs2 = crystalSymmetry('432')
center = orientation.rand(5,cs,cs2);
odf = unimodalODF(center,'halfwidth',2.5*degree)
ori = odf.calcOrientations(1000);
odf2 = calcDensity(ori,'noFourier','exact','halfwidth',3*degree)


[modes,vol,cId] = odf2.calcComponents;

for i = 1:length(modes)
  plot(ori(cId==i),'axisAngle')
  hold on
  plot(modes(i),'MarkerFaceColor','k','MarkerSize',10)
end
hold off

min(angle_outer(modes,center) ./ degree)

end
