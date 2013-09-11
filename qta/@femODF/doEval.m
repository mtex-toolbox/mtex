function f = doEval(odf,ori,varargin)
% evaluate an odf at orientation ori

% find tetrahegons and compute bariocentric coordinates
[tetra,bario] = findTetra(odf.DSO3,ori);

% get vertices of the tetrahegons -> length(ori) x 4 matrix with indices
vertices = odf.DSO3.tetra(tetra);

% set up evaluation matrix
M = sparse(repmat(1:length(ori),4,1)',vertices,bario,length(ori),length(odf.DSO3));

% compute function values 
f = M * odf.weights(:);
