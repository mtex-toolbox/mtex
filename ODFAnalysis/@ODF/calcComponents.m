function [modes, weights,centerId] = calcComponents(odf,varargin)
% heuristic to find modal orientations
%
% Syntax
%   [modes, volume] = calcComponents(odf)
%
% Input
%  odf - @ODF 
%
% Output
%  modes - modal @orientation
%  volume - volume of the component
%
% Options
%  resolution  - search--grid resolution
%
% Example
%
%   %find the local maxima of the [[SantaFe.html,SantaFe]] ODF
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

% initial seed
modes = odf.components{end}.center;
centerId = 1:length(modes);
weights = odf.components{end}.weights;

id = weights>0;
modes = reshape(modes(id),[],1);
weights = weights(id);
weights = weights ./ sum(weights);

% join orientations if possible
[modes,~,id2] = unique(modes);
centerId = id2(centerId);
weights = accumarray(id2,weights);

finished = false(size(modes));

for k = 1:maxIter

  % gradient
  g = normalize(odf.grad(modes(~finished)),1);

  % prepare for linesearch
  line_ori = exp(repmat(modes(~finished),1,length(omega)),g * omega);
  
  % evaluate along lines
  line_v = odf.eval(line_ori);
  
  % take the maximum
  [m,id] = max(line_v,[],2);
    
  % update orientions
  modes(~finished) = line_ori(sub2ind(size(line_ori),(1:length(g)).',id));
  
  finished(~finished) = id == 1;
  if all(finished), break; end

  % join orientations if possible
  [modes,~,id2] = unique(modes);
  centerId = id2(centerId);
  
  weights = accumarray(id2,weights);
  finished = accumarray(id2,finished,[],@all);
%  [length(modes), k, sum(finished)]
end

[weights,id] = sort(weights,'descend');
modes = modes(id);

end

function test
% testing code
 
cs = crystalSymmetry('432');
cs2 = specimenSymmetry;
center = orientation.rand(5,cs,cs2);
odf = unimodalODF(center,'halfwidth',5*degree)
ori = odf.calcOrientations(2000);
odf2 = calcODF(ori,'noFourier','exact','halfwidth',2.5*degree)


cs2 = crystalSymmetry('432')
center = orientation.rand(5,cs,cs2);
odf = unimodalODF(center,'halfwidth',2.5*degree)
ori = odf.calcOrientations(1000);
odf2 = calcODF(ori,'noFourier','exact','halfwidth',3*degree)


[modes,vol,cId] = odf2.calcComponents;

for i = 1:length(modes)
  plot(ori(cId==i),'axisAngle')
  hold on
  plot(modes(i),'MarkerFaceColor','k','MarkerSize',10)
end
hold off

min(angle_outer(modes,center) ./ degree)

end
