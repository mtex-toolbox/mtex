function [modes, weights] = calcComponents(odf,varargin)
% heuristic to find modal orientations
%
% Syntax
%   [modes, values] = calcModes(odf,n)
%
% Input
%  odf - @ODF 
%  n   - number of modes
%
% Output
%  modes - modal @orientation
%  values - values of the ODF at the modal @orientation
%
% Options
%  resolution  - search--grid resolution
%  accuracy    - in radians
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


maxIter = get_option(varargin,'maxIter',50);
res = get_option(varargin,'resolution',0.05*degree);
%omega = 1.25.^(-30:1:10) * degree;
omega = 1.25.^(-10:1:5) * degree;
omega(omega<res) = [];
omega = [0,omega];

% target resolution
targetRes = get_option(varargin,'resolution',0.25*degree);

% initial seed
modes = odf.components{end}.center;
weights = odf.components{end}.weights;

%id = weights>=quantile(weights,-20);
id = weights>0;
modes = reshape(modes(id),[],1);
weights = weights(id);
weights = weights ./ sum(weights);
finished = false(size(modes));

for k = 1:maxIter

  % gradient
  g = normalize(odf.grad(modes(~finished)));

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
  [modes,~,id2] = unique(modes);
  weights = accumarray(id2,weights);
  finished = accumarray(id2,finished,[],@all);
  [length(modes), k, sum(finished)]
end

[weights,id] = sort(weights,'descend');
modes = modes(id);

end
