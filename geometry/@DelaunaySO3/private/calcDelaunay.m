function I = calcDelaunay(ori)
% compute delaunay triagulation

% step 1 - restrict to fundamental region
ori = project2FundamentalRegion(ori);

% step 2 - convert to rodrigues space
R = Rodrigues(ori);

% step 3 find those close to boundaries of the fundamental region and
% duplicate them 

% get boundaries
% TODO
oR = fundamentalRegion(ori.CS);
%bounds = getFundamentalRegionRodrigues(ori.CS);

% for all boundaries
for ib = 1:length(bounds)
  
  % which are close to boundary?
  dist = dot(bounds(ib),R);  
  %boundaryOriInd{ib} = find(dist > quantile(dist,0.01));
  boundaryOriInd{ib} = 1:length(R);
  
  % apply symmetry operation
  s = rotation('Rodrigues',bounds(ib))^2;
  boundaryOri{ib} = orientation(...
    ori.subSet(boundaryOriInd{ib}) * inv(s),ori.CS,ori.SS); %#ok<MINV>
    
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
% the original orientation
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
