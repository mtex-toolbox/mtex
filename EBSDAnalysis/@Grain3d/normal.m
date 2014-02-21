function n = normal(grains)
% face normal of polyeder
%
% Input
% grains - @Grain3d
%
% Output
% n - normal of faces of the grain boundary

n = cell(size(grains,1),1);

F = grains.F;
V = grains.V;

I_FD = grains.I_FDext + grains.I_FDint;
I_FG = I_FD * grains.I_DG;

[f,g,orientation] = find(I_FG);

F = F(f,:);

n = mat2cell(bsxfun(@times,cross(V(F(:,1),:)-V(F(:,2),:),V(F(:,1),:)-V(F(:,3),:)),orientation),sum(I_FG~=0,1),3);
if size(F,2)>3
  n(:,2) = mat2cell(bsxfun(@times,cross(V(F(:,3),:)-V(F(:,4),:),V(F(:,3),:)-V(F(:,1),:)),orientation),sum(I_FG~=0,1),3);
end

n(any(cellfun('isempty',n),2),:) = [];
