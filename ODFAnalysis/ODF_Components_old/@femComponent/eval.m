function f = eval(odf,ori,varargin)
% evaluate an odf at orientation ori

% find tetrahegons and compute bariocentric coordinates
[tetra,bario] = findTetra(odf.center,ori);

% get vertices of the tetrahegons -> length(ori) x 4 matrix with indices
vertices = odf.center.tetra(tetra(:),:);

% set up evaluation matrix
M = sparse(repmat(1:length(ori),4,1)',double(vertices),bario,...
  length(ori),length(odf.center));

% compute function values 
f = M * odf.weights(:);
