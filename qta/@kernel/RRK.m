function Z = RRK(kk,h1,r1,h2,r2,CS,SS,varargin)
% TODO
% 2x Radontransformierten symmetriesierten Kern
%
%% Input
%  h1,r1 - crystal direction / specimen directions
%  h2,r2 - list of crystal direction / specimen directions
%  xray - (True/False) ob X-Ray Trafo (d.h. �ber +-h mitteln)
%
%% Output
% Matrix der Dimension von h2 x r2:
%
% allgemeine Formel:
% RRK(dr,dh) = Sum(g) Sum(l) A_l P_l(g*h1.h2)*P_l(dr)

Z = zeros(numel(h2),numel(r2));

sh = symetriceVec(CS,h1);
if check_option(varargin,'reduced'), sh = [sh,-sh];end

for i=1:length(sh)
	dh = dot_outer(sh(i)./norm(sh(i)),h2./norm(h2));
	dr = dot_outer(r1./norm(r1),r2./norm(r2));
	Z = Z + kk.RRK(dh.',dr) / length(sh);
end
