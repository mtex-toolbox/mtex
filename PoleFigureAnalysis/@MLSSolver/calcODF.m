function odf = calcODF(solver,varargin)

% display
format = [' ' repmat('  %1.2f',1,solver.pf.numPF) '\n'];

solver.initIter;

for iter = 1:10
  
  % one step
  solver.doIter;
  
  % compute residual error
  for i = 1:solver.pf.numPF
    err(i) = norm(solver.u{i}) ./ norm(solver.pf.allI{i}(:));
  end
  fprintf(format,err)
  
end

% extract result
odf = solver.pdf;

end