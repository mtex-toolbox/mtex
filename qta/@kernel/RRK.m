function Z = RRK(kk,h1,r1,h2,r2,CS,SS,varargin)
% TODO
% 2x Radontransformierten symmetriesierten Kern
%
%% Input
%  h1,r1 - crystal direction / specimen directions
%  h2,r2 - list of crystal direction / specimen directions
%% Flags
%  antipodal - 
%
%% Output
% Z - Matrix der Dimension von h2 x r2
%
%% Remarks
% allgemeine Formel:
%
% $$\mathcal{RR}K(dr,dh) = \sum_g \sum_l A_l P_l(gh_1,h_2)*P_l(dr)$$

Z = zeros(numel(h2),numel(r2));

sh = symmetrise(vector3d(h1),CS,varargin{:});
h2 = vector3d(h2./norm(h2));
sr = symmetrise(r1,SS);

for i = 1:numel(sh)
  dh = dot_outer(sh(i)./norm(sh(i)),h2);
  for j = 1:numel(sr)
    dr = dot_outer(sr(j)./norm(sr(j)),r2./norm(r2));
    Z = Z + kk.RRK(dh.',dr) / numel(sh);
  end
end
