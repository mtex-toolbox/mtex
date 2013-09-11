classdef DelaunaySO3 < orientation

  properties
    
    I_oriTetra     % incidence matrix between orientatios and tetrahegons    
    A_tetra        % adjecence matrix between tetrahegons
    tetraNeighbour % neigbouring tetraeders orderd as faces
    lookup         % lookup table orientation -> tetrahedrons
                       
  end
  
  properties (Dependent = true)
    
    tetra % list of vertices of the tetrahegons
    A_ori % oriention adjecents matrix
    
  end
  
  
  methods
    
    function DSO3 = DelaunaySO3(varargin)
      
      DSO3 = DSO3@orientation(varargin{:});
    
      % compute incintence matrix
      DSO3.I_oriTetra = calcDelaunay2(DSO3);
    
      % compute adjacence matrices
      DSO3.A_tetra = (DSO3.I_oriTetra * DSO3.I_oriTetra')==3;
      
      % compute neighbouring list
      DSO3.tetraNeighbour = calcNeighbour(DSO3);
      
      % compute lookup table
%      DSO3.lookup = calcLookUp(DSO3);
      
    end
  
    function tetra = get.tetra(DSO3)
      
      [u,~] = find(DSO3.I_oriTetra.');
      tetra = reshape(u,4,[]).';
      
    end
    
end

end

% ------------------------------------------------------
function N = calcNeighbour(DSO3)
% compute which tetrahegons are connceted by which face

[u,v] = find(DSO3.A_tetra); % v is sorted
s = DSO3.tetra(v,:) - DSO3.tetra(u,:);

% side is first minus of s or last plus
[ind,side] = max(s<0,[],2);
% or last plus
[~,side2] = max(fliplr(s>0),[],2);
side(~ind) = 5-side2(~ind);

% set up neigbouring list
ind = 4*(0:(size(DSO3.A_tetra,1)-1));
ind = repmat(ind,4,1) + reshape(side,4,[]);
N(ind) = u;
N = reshape(N,4,[]).';

% % set up extendet adjecency matrix
% % such that [u,v,value] = find(A_tetra) value(k) is the side of the tetrahegon v(k) where u(k) touches
%DSO3.A_tetra = sparse(u,v,side,size(DSO3.A_tetra,1),size(DSO3.A_tetra,1));
%DSO3.A_ori = (DSO3.I_oriTetra' * DSO3.I_oriTetra)>0;
      
end


function I = calcDelaunay(ori)
% compute delaunay triagulation

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
  %boundaryOriInd{ib} = find(dist > quantile(dist,0.01));
  boundaryOriInd{ib} = 1:length(R);
  
  % apply symmetry operation
  s = rotation('Rodrigues',bounds(ib))^2;
  boundaryOri{ib} = orientation(...
    subsref(ori,boundaryOriInd{ib}) * inv(s),ori.CS,ori.SS); %#ok<MINV>
    
  % check that the rotated nodes are indeed outside the fundamental region
  %ind = boundaryOri{ib}.checkFundamentalRegion;
  %boundaryOriInd{ib}(ind) = [];
  %boundaryOri{ib}(ind) = [];
  
end
boundaryOriInd = vertcat(boundaryOriInd{:});

% step 4 - Delaunay triangulation
% generate points on the four dimensional hemisphere
X = vertcat(ori(:),boundaryOri{:});
% that are close to (1,0,0,0)
q = squeeze(double(X));
ind = q(:,1) < 0;
q(ind) = -q(ind);

% output K is a list of M tetrahegons, i.e., it is a M x 4 matrix
% where the m-th line contains the indices of the points of the m-th
% tetrahegon
K = convhulln(q);

% step 5 - remove tetrahegons completely outside the fundamental region
% and replace indices to symmetrised orientations by the indices of
% the original orienation
ind = K > length(ori);
K(ind) = boundaryOriInd(K(ind)-length(ori));
K(all(ind,2),:) = [];

% this should be equal
% sum(sum(ind')==1) == sum(sum(ind')==3)

% there might be duplicated tetrahegons - remove them
K = sortrows(sort(K,2));
K = unique(K,'rows');

% there also may be bad tetragonals
K(any(~diff(K,1,2),2),:) = [];

% step 6 - set up the orientations - tetrahegons incidence matrix 
I = sparse(repmat((1:size(K,1))',1,4),K,1,size(K,1),length(ori));

end

function I = calcDelaunay2(ori)
% compute delaunay triagulation

% step 1 - restrict to fundamental region
ori = project2FundamentalRegion(ori);

% step 2 - symmetrise
sori = symmetrise(ori).';

% step 3 - Delaunay triangulation
% generate points on the four dimensional hemisphere
% that are close to (1,0,0,0)
q = reshape(double(sori),[],4);
q = [q;-q];

% output K is a list of M tetrahegons, i.e., it is a M x 4 matrix
% where the m-th line contains the indices of the points of the m-th
% tetrahegon
K = convhulln(q);
K = sortrows(sort(K,2));

% step 4 - remove tetrahegons completely outside the fundamental region
% and replace indices to symmetrised orientations by the indices of
% the original orienation
ind = K > length(ori);
K(all(ind,2),:) = [];
KK = 1+mod(K-1,length(ori));

% this should be equal
% sum(sum(ind')==1) == sum(sum(ind')==3)

% there might be duplicated tetrahegons - remove them
KK = sortrows(sort(KK,2));
KK = unique(KK,'rows');

% find bad  tetragonals
ind = find(any(~diff(KK,1,2),2));

%
%tetramesh(KK,squeeze(double(ori.axis .* ori.angle)),'facealpha',0.5)


% step 6 - set up the orientations - tetrahegons incidence matrix 
I = sparse(repmat((1:size(KK,1))',1,4),KK,1,size(KK,1),length(ori));

end
