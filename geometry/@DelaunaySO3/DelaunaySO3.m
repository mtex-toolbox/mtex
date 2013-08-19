classdef DelaunaySO3 < orientation

  properties
    
    I_oriTetra % incidence matrix between orientatios and tetrahegons
    A_ori      % oriention adjecents matrix
    A_tetra
    
    
  end
  
  methods
    
    function DSO3 = DelaunaySO3(varargin)
      
      DSO3 = DSO3@orientation(varargin{:});
    
      % compute incintence matrix
      DSO3.I_oriTetra = calcDelaunay(DSO3);
    
      % compute adjacence matrices
      DSO3.A_tetra = (DSO3.I_oriTetra * DSO3.I_oriTetra')>2;
        
      DSO3.A_ori = (DSO3.I_oriTetra' * DSO3.I_oriTetra)>0;
      
    end
  
    function [ind,k] = find(DSO3,ori)
    % find to a list of orienations the corresponding tetrahegon and its
    % edge orientations
    
    
    ori = project2FundamentalRegion(ori);
    
      
    
    
    
    end
    
    
end

end

function I = calcDelaunay(ori)


% step 1 - restrict to fundamental region
ori = project2FundamentalRegion(ori);

% step 2 - convert to rodrigues space
R = Rodrigues(ori);

% step 3 find those close to boundaries of the fundamental region and
% duplicate them 

% get boundaries
bounds = getFundamentalRegionRodrigues(ori.CS);

% for all boundaries
for ib = 1:length(bounds)
  
  % which are close to boundary?
  dist = dot(bounds(ib),R);  
  boundaryOriInd{ib} = find(dist > quantile(dist,0.9));
  
  % apply symmetry operation
  s = rotation('Rodrigues',bounds(ib))^2;
  boundaryOri{ib} = orientation(...
    subsref(ori,boundaryOriInd{ib}) * inv(s),ori.CS,ori.SS); %#ok<MINV>
    
  % check that the rotated nodes are indeed outside the fundamental region
  ind = boundaryOri{ib}.checkFundamentalRegion;
  boundaryOriInd{ib}(ind) = [];
  boundaryOri{ib}(ind) = [];
  
end
boundaryOriInd = vertcat(boundaryOriInd{:});

% step 4 - Delaunay triangulation
X = vertcat(ori(:),boundaryOri{:});

% output K is a list of M tetrahegons, i.e., it is a M x 4 matrix
% where the m-th line contains the indices of the points of the m-th
% tetrahegon
K = convhulln(squeeze(double(X)));

% step 5 - remove tetrahegons completely outside the fundamental region
% and replace indices to symmetrised orientations by the indices of
% the original orienation
ind = K > length(ori);
K(ind) = boundaryOriInd(K(ind)-length(ori));
K(all(ind,2),:) = [];

% step 6 - set up the orientations - tetrahegons incidence matrix 
I = sparse(repmat((1:size(K,1))',1,4),K,1,size(K,1),length(ori));

end

function check


tic

q = SO3Grid(1000000);

d = squeeze(double(q));

[K, v] = convhulln(d);

toc

%

cs = symmetry('m-3m');


for k = 1:numel(cs)
  
  
  q1 = cs(k)*q;
  
end


%

end
