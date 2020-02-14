function initIter(solver)

% maybe no starting vector of coefficients has been specified
if isempty(solver.c)
  solver.c = ones(length(solver.S3G),1) ./ length(solver.S3G);
end

for i = 1:numPF(solver.pf)
  % step 2
  I_i = solver.pf.allI{i}(:);
  solver.a{i} = solver.Mtv(ones(length(I_i),1),i) ./ sum(I_i);
  
  % step 3 alpha_i = 1/
  solver.alpha(i) = 1 ./ (solver.a{i}.' * solver.c);
      
  % step 5 u_i = (alpha_i Psi_i c - I_i) .* weights
  solver.u{i} = (solver.Mv(solver.c,i) * solver.alpha(i) - I_i) .* solver.weights{i};
  
end

% step 4: regularization
if solver.lambda>0
  solver.initRegularisation;
  solver.alpha(i+1) = 1./sum(solver.c);
  solver.u{i+1} = solver.alpha(i+1) * (solver.RM * solver.c);
end

end

