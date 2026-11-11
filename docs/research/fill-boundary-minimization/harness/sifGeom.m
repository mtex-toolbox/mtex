function G = sifGeom(out)
% lattice coordinates in which cell (i,j) of the raster out.fill is the Voronoi cell of (i,j)
G.toP = out.cell2pos;
G.sz = size(out.fill);
c = round(G.sz / 2);
G.M = G.toP(c + eye(2)) - G.toP(c);
G.toU = @(p) toCell(p,G.toP(c) - c * G.M,G.M,G.toP);
G.obst = ~out.fill;
end
function u = toCell(p,p0,M,toP)
u = (p - p0) / M;
for it = 1:4, u = u + (p - toP(u)) / M; end
end
