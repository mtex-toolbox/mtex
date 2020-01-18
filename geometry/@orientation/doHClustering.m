function [c,center] = doHClustering(ori,varargin)
% sort orientations into clusters
%
% Syntax
%   [c,center] = doHCluster(ori,'numCluster',n)
%   [c,center] = doHCluster(ori,'maxAngle',omega)
%
% Input
%  ori - @orientation
%  n   - number of clusters
%  omega - maximum angle 
%
% Output
%  c - list of clusters
%  center - center of the clusters
%
% Example 
%
%   % generate orientation clustered around 5 centers
%   cs = crystalSymmetry('m-3m');
%   center = orientation.rand(5,cs); 
%   odf = unimodalODF(center,'halfwidth',5*degree)
%   ori = odf.calcOrientations(3000);
%
%   % find the clusters and its centers
%   tic; [c,centerRec] = calcCluster(ori,'method','hierarchical','numCluster',5); toc
%
%   % visualize result
%   oR = fundamentalRegion(cs)
%   plot(oR)
% 
%   hold on
%   plot(ori,ind2color(c))
%   caxis([1,5])
%   plot(center,'MarkerSize',10,'MarkerFaceColor','k','MarkerEdgeColor','k')
%   plot(centerRec,'MarkerSize',10,'MarkerFaceColor','r','MarkerEdgeColor','k')
%   hold off 
%
%   %check the accuracy of the recomputed centers
%   min(angle_outer(center,centerRec)./degree)
%
%   odfRec = calcDensity(ori)
%   [~,centerRec2] = max(odfRec,5)
%   min(angle_outer(center,centerRec2)./degree)
%

% If the statistics toolbox is installed the following is also possible
% though it does not work so well
% d = angle_outer(ori,ori);
% tic;z = linkage(d);toc
% c = cluster(z,'maxclust',5);


% extract weights
weights = get_option(varargin,'weights',ones(size(ori)));

if length(ori)>1000 && ~check_option(varargin,'exact')

  % define a indexed grid
  res = get_option(varargin,'resolution',2.5*degree);
  if ori.antipodal, aP = {'antipodal'}; else, aP = {}; end
  S3G = equispacedSO3Grid(ori.CS,ori.SS,'resolution',res,aP{:});

  % construct a sparse matrix showing the relation between both grids
  M = sparse(1:length(ori),find(S3G,ori),weights,length(ori),length(S3G));

  % compute weights
  weights = full(sum(M,1)).';
  
  % eliminate spare rotations in grid
  S3G = subGrid(S3G,weights~=0);
  weights = weights(weights~=0);

  % apply clustering to grid
  [~,center] = doHClustering(S3G,varargin{:},'weights',weights,'exact');

  % performe one step 
  d = angle_outer(ori,center);
  [~,c] = min(d,[],2);
  
  % recompute center
  %center = repmat(ori.subSet(1),n,1);  
  for i = 1:length(center)
    center = subsasgn(center,i,mean(ori.subSet(c==i),'robust'));
  end
  center = subsasgn(center,isnan(center),[]);
  
  % performe one step 
  d = angle_outer(ori,center);
  [~,c] = min(d,[],2);
  
  % sort center
  counts = accumarray(c,1,[length(center),1]);
  [counts,id] = sort(counts,'descend');
  center = subsasgn(center,id,center);
  [~,cid] = sort(id);
  c = cid(c);
  
  % it may happen that we end up with less center
  center = subsasgn(center,counts==0,[]);
  
  return
end

n = get_option(varargin,'numCluster',2);
maxOmega = get_option(varargin,'maxAngle',inf);

% start with as many clusters as orientations
% incidence matrix orientations - clusters
I_OC = spdiags(weights(:),0,length(weights),length(weights));

% compute the distance between all orientations
%d = full(abs(dot_outer(ori,ori,'epsilon',20*degree)));
d = full(abs(dot_outer(ori,ori,'epsilon',20*degree)));
d(sub2ind(size(d),1:length(ori),1:length(ori))) = 0;
center = orientation(ori);

progress(0,length(ori));
while 1
  
  if length(center) <= n, break; end
    
  % find smallest pair
  [omega,id] = max(d(:));
  
  if omega<cos(maxOmega), break; end
  
  [i,j] = ind2sub(size(d),id);

  % update orientations
  weights = full(sum(I_OC(:,[i,j]),2));
  m = mean(ori.subSet(weights>0),'weights',weights(weights>0),'robust');
    
  center.a(i) = m.a;
  center.b(i) = m.b;
  center.c(i) = m.c;
  center.d(i) = m.d;
  
  % update incidence matrix
  I_OC(:,i) = I_OC(:,i) + I_OC(:,j);
  I_OC(:,j) = [];

  % update distance matrix
  dd = dot(m,center);
  dd(i) = 0;
  d(i,:) = dd;
  d(:,i) = dd.';
  d(:,j) = [];
  d(j,:) = [];
  center.a(j) = [];
  center.b(j) = [];
  center.c(j) = [];
  center.d(j) = [];
  center.i(j) = [];
  
  progress(length(ori)-length(center),length(ori));
end

progress(length(ori),length(ori));

[c,~] = find(I_OC.');

end
