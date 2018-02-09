function plot(S1G)
% plot grid

if S1G(1).periodic
  rho = (S1G.points - S1G.min)*2*pi/(S1G.max-S1G.min);
  theta = repmat(pi/2,1,length(rho));
  plot(vector3d('theta',theta,'rho',rho),strtrim(cellstr(num2str(S1G.points(:)))));
else
  y = ones(1,1,GridLength(S1G));
  plot(S1G.points,y,'.','MarkerSize',10);
end
