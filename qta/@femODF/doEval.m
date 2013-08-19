function f = doEval(odf,ori,varargin)
% evaluate an odf at orientation ori

% find tetrahegon for each ori -> length(ori) x 4 indice matrix 
vertices = findVertices(odf.DSO3,ori);

% compute distance to all edges
d = dot(repmat(ori(:),[],4),DSO3(vertices));

% compute interpolation coefficients within each tetrahegon
c = d;

% compute interpolation weights and set up evaluation matrix
M = sparse(repmat(1:length(ori),4,1)',vertices,c,length(ori),length(odf.DSO3));

% compute function values 
f = M * odf.weights(:);