function G = calcGrid(Gtheta,Grho)
% calculate grid from theta, rho
%
% input
%  theta, rho - S1Grid
%
% output
%  S2G - @vector3d

theta = double(Gtheta);
theta = repelem(theta,GridLength(Grho));
rho = double(Grho);

G = vector3d.byPolar(theta,rho);
if all(GridLength(Grho) == GridLength(Grho(1)))
  G = reshape(G,GridLength(Grho(1)),length(Grho));
end
