function t = subSet(t,ind)
% subindex vector3d

switch t.rank
  case 0, t.M = t.M(ind);
  case 1, t.M = t.M(:,ind);
  case 2, t.M = t.M(:,:,ind);
  case 3, t.M = t.M(:,:,:,ind);
  case 4, t.M = t.M(:,:,:,:,ind);
end
  
end
