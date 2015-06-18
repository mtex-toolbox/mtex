function [q,alpha] = medianFilter(q,alpha)
% smooth spatial orientation data
%
% Input
%  q     - @quaternion
%  alpha - smoothing parameter

% make q a bit larger
nanRow = nanquaternion(1,size(q,2)+2);
nanCol = nanquaternion(size(q,1),1);

q = [nanRow;[nanCol,q,nanCol];nanRow];

meanDist = zeros([size(q)-2,3,3]);

for i = 1:3
  for j = 1:3
    
    qq = q(i+(0:end-3),j+(0:end-3));
    meanDist(:,:,i,j) = nanmean(cat(3,...
      angle(qq,q(1:end-2,1:end-2)), ...
      angle(qq,q(1:end-2,2:end-1)), ...
      angle(qq,q(1:end-2,3:end-0)), ...
      angle(qq,q(2:end-1,1:end-2)), ...
      angle(qq,q(2:end-1,2:end-1)), ...
      angle(qq,q(2:end-1,3:end-0)), ...
      angle(qq,q(3:end-0,1:end-2)), ...
      angle(qq,q(3:end-0,2:end-1)), ...
      angle(qq,q(3:end-0,3:end-0))),3);
    
  end
end

% find median
meanDist = reshape(meanDist,[size(qq),9]);
[~,id] = min(meanDist,[],3);

[i,j] = ind2sub(size(qq),1:prod(size(qq)));
[ii,jj] = ind2sub([3 3],id);

ii(isnan(q.a(2:end-1,2:end-1))) = 2;
jj(isnan(q.a(2:end-1,2:end-1))) = 2;
ind = sub2ind(size(q),i(:)+ii(:)-1,j(:)+jj(:)-1);

% store median
q = q(ind);

