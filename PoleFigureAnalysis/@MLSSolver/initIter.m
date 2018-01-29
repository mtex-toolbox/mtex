function initIter(solver)

for i = 1:solver.NP
  % step 2
  solver.a{i} = solver.Mtv(ones(Ni,1),i) ./ sum(solver.I{i});
  
  % step 3 alpha_i = 1/
  solver.alpha{i} = 1 ./ (solver.a{i} * c.');
  
  % step 4 
  % todo: regularization
  
  % step 5 u_i = (alpha_i Psi_i c - I) .* weights
  solver.u{i} = (solver.Mv(solver.c,i) * solver.alpha{i} - solver.I) .* solver.weigths{i};
  
end

end