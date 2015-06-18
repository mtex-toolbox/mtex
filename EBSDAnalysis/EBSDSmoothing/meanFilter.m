function [q,alpha] = meanFilter(q,alpha)
% smooth spatial orientation data
%
% Input
%  q     - @quaternion
%  alpha - smoothing parameter

% make q a bit larger
nanRow = nanquaternion(1,size(q,2)+2);
nanCol = nanquaternion(size(q,1),1);

q = [nanRow;[nanCol,q,nanCol];nanRow];

% map into tangential space
tq = reshape(log(q),[size(q),3]);

% take the mean
tqStacked = nanmean(cat(4,tq(2:end-1,2:end-1,:),...
  tq(1:end-2,2:end-1,:),...
  tq(3:end,2:end-1,:),...
  tq(2:end-1,1:end-2,:),...
  tq(2:end-1,3:end,:),...
  tq(1:end-2,1:end-2,:),...
  tq(1:end-2,3:end,:),...
  tq(3:end,1:end-2,:),...
  tq(3:end,3:end,:)),...
  4);

% map back to orientation space
q = reshape(expquat(reshape(tqStacked,[],3)),size(tqStacked,1),size(tqStacked,2));
