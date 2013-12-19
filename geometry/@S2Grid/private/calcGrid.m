function G = calcGrid(Gtheta,Grho)
% calculate grid from theta, rho
%
% input:  theta, rho - S1Grid
% output: vector3d

theta = double(Gtheta);
theta = rep(theta,GridLength(Grho));
rho = double(Grho);

G = sph2vec(theta,rho);
if all(GridLength(Grho) == GridLength(Grho(1)))
  G = reshape(G,GridLength(Grho(1)),length(Grho));
end