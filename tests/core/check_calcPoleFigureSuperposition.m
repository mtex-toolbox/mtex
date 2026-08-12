function check_calcPoleFigureSuperposition
% check that calcPoleFigure simulates superposed pole figures
%
% A pole figure may superpose several crystal directions - the third pole
% figure of the dubna data set superposes (10-11) and (01-11). The default
% structure coefficients of calcPoleFigure were built as one per pole
% figure, repcell(1,1,length(h)), so calcPDF returned one value per Miller
% index and the reshape to size(r{ip}) threw "Number of elements must not
% change". The only way to simulate such a data set was to pass the
% measured coefficients, calcPoleFigure(odf,pf.allH,pf.allR,'superposition',pf.c).
%
% The default is now one coefficient per crystal direction, all equal, so
% that a superposed pole figure is the mean of its components and hence
% again a pole density.

rng(0)

cs = crystalSymmetry('321');
odf = unimodalODF(orientation.rand(cs),'halfwidth',15*degree);

h = {Miller(1,0,0,cs); [Miller(1,0,-1,1,cs); Miller(0,1,-1,1,cs)]};
r = repcell(regularS2Grid('resolution',10*degree),2,1);

checkDefaultIsTheMean(odf,h,r);
checkExplicitCoefficients(odf,h,r);
checkPlainPoleFigureUnchanged(odf,h{1},r{1});
checkDubna;

disp('check_calcPoleFigureSuperposition: passed');

end

% =========================================================================
function checkDefaultIsTheMean(odf,h,r)

pf = calcPoleFigure(odf,h,r);

c = pf.c;
assert(numel(c{2}) == 2 && all(abs(c{2} - 0.5) < 1e-12), ...
  'check_calcPoleFigureSuperposition: default coefficients are %s, expected [0.5 0.5]', ...
  mat2str(c{2}))

I = pf.allI{2};
ref = 0.5*calcPDF(odf,h{2}(1),r{2},'antipodal') + ...
  0.5*calcPDF(odf,h{2}(2),r{2},'antipodal');

assert(max(abs(I(:) - ref(:))) < 1e-10, ...
  'check_calcPoleFigureSuperposition: the superposed pole figure is not the mean of its components, max deviation %g', ...
  max(abs(I(:) - ref(:))))

end

% -------------------------------------------------------------------------
function checkExplicitCoefficients(odf,h,r)
% coefficients handed over are used as they are, unnormalized

c = {1, [0.52 1.23]};

pf = calcPoleFigure(odf,h,r,'superposition',c);

I = pf.allI{2};
ref = c{2}(1)*calcPDF(odf,h{2}(1),r{2},'antipodal') + ...
  c{2}(2)*calcPDF(odf,h{2}(2),r{2},'antipodal');

assert(max(abs(I(:) - ref(:))) < 1e-10, ...
  'check_calcPoleFigureSuperposition: explicit coefficients are not honoured, max deviation %g', ...
  max(abs(I(:) - ref(:))))

end

% -------------------------------------------------------------------------
function checkPlainPoleFigureUnchanged(odf,h,r)
% a pole figure of a single crystal direction still gets the coefficient 1

pf = calcPoleFigure(odf,h,r);

c = pf.c;
assert(isscalar(c{1}) && abs(c{1} - 1) < 1e-12, ...
  'check_calcPoleFigureSuperposition: a plain pole figure got the coefficient %s instead of 1', ...
  mat2str(c{1}))

I = pf.allI{1};
ref = calcPDF(odf,h,r,'antipodal');

assert(max(abs(I(:) - ref(:))) < 1e-10, ...
  'check_calcPoleFigureSuperposition: a plain pole figure is not its pole density function')

end

% -------------------------------------------------------------------------
function checkDubna
% the reported case, on the data set it was reported with

pf = mtexdata('dubna');
odf = calcODF(pf,'silent');

sim = calcPoleFigure(odf,pf.allH,pf.allR);

assert(numel(sim.allH) == numel(pf.allH), ...
  'check_calcPoleFigureSuperposition: simulated %d pole figures instead of %d', ...
  numel(sim.allH), numel(pf.allH))

for k = 1:numel(sim.allH)
  assert(numel(sim.c{k}) == length(pf.allH{k}), ...
    'check_calcPoleFigureSuperposition: pole figure %d has %d coefficients for %d crystal directions', ...
    k, numel(sim.c{k}), length(pf.allH{k}))
  assert(all(size(sim.allI{k}) == size(pf.allR{k})), ...
    'check_calcPoleFigureSuperposition: pole figure %d has %s intensities on %s directions', ...
    k, mat2str(size(sim.allI{k})), mat2str(size(pf.allR{k})))
end

end
