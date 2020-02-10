function [c,center] = doHClustering(obj,varargin)
% hirarchical clustering of rotations and vectors
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


% approximate clustering on a grid for very large data sets
if length(obj)>1000 && ~check_option(varargin,'exact')
  
  [c,center] = gridCluster(obj,varargin{:});
  return
end

% extract weights
weights = get_option(varargin,'weights',ones(size(obj)));

n = get_option(varargin,'numCluster',2);
maxOmega = get_option(varargin,'maxAngle',inf);

% start with as many clusters as objects
% incidence matrix objects - clusters
I_OC = spdiags(weights(:),0,length(weights),length(weights));

% compute the distance between all objects
d = full(dot_outer(obj,obj));
d(sub2ind(size(d),1:length(obj),1:length(obj))) = 0;

center = obj(1:end);

progress(0,length(obj));
while 1
  
  if length(center) <= n, break; end
    
  % find smallest pair
  [omega,id] = max(d(:));
  
  if omega<cos(maxOmega), break; end
  
  [i,j] = ind2sub(size(d),id);

  % update cluster centers    
  weights = full(sum(I_OC(:,[i,j]),2));
  m = mean(obj(weights>0),'weights',weights(weights>0));
  center(i) = m;
     
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
  center(j) = [];
    
  progress(length(obj)-length(center),length(obj));
end

progress(length(obj),length(obj));

[c,~] = find(I_OC.');

end

function [c,center] = gridCluster(obj,varargin)

[objG,wG] = gridify(obj,varargin{:});

if isa(objG,'S2Grid'), objG = vector3d(objG); end
  
% apply clustering to grid
[~,center] = doHClustering(objG,varargin{:},'weights',wG,'exact');

% reassign clusters
d = angle_outer(obj,center);
[~,c] = min(d,[],2);
  
% recompute center
for i = 1:length(center)
  center(i) = mean(obj(c==i),'robust');
end
center(isnan(center)) = [];
  
% reassign clusters once more
d = angle_outer(obj,center);
[~,c] = min(d,[],2);
  
% sort center
counts = accumarray(c,1,[length(center),1]);
[counts,id] = sort(counts,'descend');
center(id) = center;
[~,cid] = sort(id);
c = cid(c);
  
% it may happen that we end up with less center
center(counts==0) = [];
  
end

