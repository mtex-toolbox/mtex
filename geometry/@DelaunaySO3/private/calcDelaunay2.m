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
K = int32(convhulln(q));
K = sortrows(sort(K,2));

% step 4 - remove tetrahegons completely outside the fundamental region
% and replace indices to symmetrised orientations by the indices of
% the original orientation
ind = K > length(ori);
K(all(ind,2),:) = [];
tetra = 1+mod(K-1,length(ori));

% there might be duplicated tetrahegons - remove them
tetra = sortrows(sort(tetra,2));
tetra = unique(tetra,'rows');

end
