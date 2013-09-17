classdef DelaunaySO3 < orientation

  properties
        
    tetra          % list of vertices of the tetrahegons
    tetraNeighbour % neigbouring tetraeders orderd as faces
    lookup         % lookup table orientation -> tetrahedrons
                       
  end
    
  methods
    
    function DSO3 = DelaunaySO3(varargin)
      
      DSO3 = DSO3@orientation(varargin{:});
    
      % compute tetrahegons
      if check_option(varargin,'tetra')
        DSO3.tetra = get_option(varargin,'tetra');
      else
        DSO3.tetra = calcDelaunay2(DSO3);
      end
      
      % compute neighbouring list
      DSO3.tetraNeighbour = calcNeighbour(DSO3.tetra);
      
      % compute lookup table
      res = 40*degree;
      for i = 1:3
        res = res / 2;
        DSO3.lookup = calcLookUp(DSO3,res);
      end
    end
          
end

end

% ------------------------------------------------------

function lookup = calcLookUp(DSO3,res)

[max_phi1,max_Phi,max_phi2] = getFundamentalRegion(DSO3.CS,DSO3.SS);

phi1 = 0:res:max_phi1;
Phi = 0:res:max_Phi;
phi2 = 0:res:max_phi2;

[phi1,Phi,phi2] = ndgrid(phi1,Phi,phi2);

ori = orientation('Euler',phi1,Phi,phi2);

lookup = reshape(DSO3.findTetra(ori),size(ori));

end

function N = calcNeighbour(tetra)
% compute which tetrahegons are connceted by which face

% indicence matrix tetra -> ori
I = sparse(repmat((1:size(tetra,1))',1,4),tetra,1);
      
% compute adjacence matrices
A = (I * I')==3;

[u,v] = find(A); % v is sorted
s = tetra(v,:) - tetra(u,:);

% side is first minus of s or last plus
[ind,side] = max(s<0,[],2);
% or last plus
[~,side2] = max(fliplr(s>0),[],2);
side(~ind) = 5-side2(~ind);

% set up neigbouring list
ind = 4*(0:(size(A,1)-1));
ind = repmat(ind,4,1) + reshape(side,4,[]);
N(ind) = u;
N = reshape(N,4,[]).';
     
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

function tetra = calcDelaunay2(ori)
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
tetra = 1+mod(K-1,length(ori));

% there might be duplicated tetrahegons - remove them
tetra = sortrows(sort(tetra,2));
tetra = unique(tetra,'rows');

end
