function d = diameter(gB)
% diameter of a grain in measurement units
% longest distance between any two vertices of the grain boundary

F = gB.F;
d = zeros(size(gB));

% get the coordinates
V = gB.allV.xyz;
b = iscell(F);

for ig = 1:length(gB)

  if b; Vg = V(F{ig},:); else; Vg = V(F(ig,:),:); end
  
  diffVg = reshape(Vg,[],1,3) - reshape(Vg,1,[],3);
  diffVg = sum(diffVg.^2,3);

  d(ig) = sqrt(max(diffVg(:)));
end
