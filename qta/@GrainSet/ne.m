function out = ne(g1,g2)

out = nnz(xor(g1.I_DG,g2.I_DG)) ~= 0;
