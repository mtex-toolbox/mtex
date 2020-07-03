function init(solver,varargin)

% extract pole figures
pf = solver.pf;

% kernel coefficents
A = solver.psi.A(:);
A = A ./ (2*(0:length(A)-1)+1).';
if pf.antipodal
  A(2:2:end) = 0;
else
  warning('MTEX:missingFlag','Flag antipodal not set in PoleFigure data!');
end
bw = length(A)-1;
nfsftmex('precompute', bw, 1000, 1, 0);

% extend coefficients
solver.A = repelem(A,2*(0:bw)+1);

% free previously allocated nfft plans
solver.free_nfft;

% set up gh nfft's
for i = 1:pf.numPF
  
  % TODO: consider the case of no antipodal symmetry
  for j = 1:length(pf.allH{i})
    h{j} = unique(symmetrise(pf.allH{i}(j)),'noSymmetry','antipodal');
    l(j) = length(h{j});
  end
    
  % compute points in the pole figure
  gh = solver.S3G * vertcat(h{:}); % S3G x SS x h
  
  solver.nfft_gh(i) = nfsftmex('init_advanced', bw, length(gh), 1);
  nfsftmex('set_x', solver.nfft_gh(i), [gh.rho(:)'; gh.theta(:)']); % set vertices
  nfsftmex('precompute_x', solver.nfft_gh(i));
  
  % set up superposition coefficients
  solver.refl{i} = repelem(pf.c{i}./l, l);
end

% set up  r nfft's
for i = 1:pf.numPF
  r = solver.SS.properGroup * solver.pf.allR{i};
  solver.nfft_r(i) = nfsftmex('init_advanced', bw, length(r), 1);
  nfsftmex('set_x', solver.nfft_r(i), [r.rho(:).'; r.theta(:).']); % set vertices
  nfsftmex('precompute_x', solver.nfft_r(i));
end
