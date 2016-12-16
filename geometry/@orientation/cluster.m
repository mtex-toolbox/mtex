function [c,ori] = cluster(ori,n)
% sort orientations into clusters
%
% Syntax
%   [c,center] = cluster(ori,n)
%
% Input
%  ori - @orientation
%  n   - number of clusters
%
% Output
%  c - list of clusters
%  center - center of the clusters
%

% start with as many clusters as orientations
% incidence matrix orientations - clusters
I_OC = speye(length(ori));

% compute the distance between all orientations
d = angle_outer(ori,ori) + 100*eye(length(ori));

while length(ori) > n

  % find smalles pair
  [~,id] = min(d(:));
  [i,j] = ind2sub(size(d),id);

  % update orientations
  m = mean(ori.subSet([i,j]),full(sum(I_OC(:,[i,j]))),'robust');
  ori.a(i) = m.a;
  ori.b(i) = m.b;
  ori.c(i) = m.c;
  ori.d(i) = m.d;
  
  % update incidence matrix
  I_OC(:,i) = I_OC(:,i) + I_OC(:,j);
  I_OC(:,j) = [];

  % update distance matrix
  d(i,:) = angle(m,ori);
  d(:,i) = d(i,:).';
  d(i,i) = 100;
  d(:,j) = [];
  d(j,:) = [];
  ori.a(j) = [];
  ori.b(j) = [];
  ori.c(j) = [];
  ori.d(j) = [];
  ori.i(j) = [];
end

[c,~] = find(I_OC.');

end


% testing code
% cs = crystalSymmetry('mmm');
% ori = orientation.rand(5,cs); 
% odf = unimodalODF(ori)
% ori = odf.calcOrientations(1000);
% tic; c = cluster(ori,5); toc
% oR = fundamentalRegion(cs)
% plot(oR)
% 
% hold on,plot(ori.project2FundamentalRegion,c), hold off
% caxis([1,5])



