function b = eq(G1,G2)
% implements G1 == G2

b = all(G1.points == G2.points);
