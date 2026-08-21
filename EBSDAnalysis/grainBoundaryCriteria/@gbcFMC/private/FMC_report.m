function FMC_report(obj,mineral,numClusters,hier,intp)
% print what one FMC run did, for gbcFMC('verbose')
%
% The interesting question about an FMC run is not how long it took but
% WHERE in the hierarchy the answer came from: how fast the graph coarsened,
% at which scales the aggregates started carrying a lattice gradient, and at
% which scale each pixel was finally read off. A grain map read entirely off
% the top scale means the saliency selection did nothing; one read off in the
% middle means the hierarchy kept coarsening past the grains, which is what
% it is supposed to do.
%
% Input
% One of these is printed per indexed phase, since gbcFMC clusters each
% phase on its own.
%
% Input
%  obj         - the @gbcFMC, for the parameters it ran with
%  mineral     - name of the phase that was clustered
%  numClusters - number of aggregates at each scale, numClusters(1) = pixels
%  hier        - report fields collected while coarsening, from FMC_MTEX
%  intp        - report fields from reading the hierarchy, FMC_interpret
%
% See also
% gbcFMC FMC_MTEX FMC_interpret

numS = numel(numClusters);

par = sprintf('cmaha %g, cmaha0 %g, quatmax %g, alpha %g, gammaW %g', ...
  obj.cmaha, obj.cmaha0, obj.quatmax, obj.alpha, obj.gammaW);
if obj.minPixel > 1, par = [par sprintf(', minPixel %g',obj.minPixel)]; end
if isfinite(obj.maxDelta), par = [par sprintf(', maxDelta %g',obj.maxDelta)]; end

if isempty(mineral), mineral = 'unnamed phase'; end

fprintf('\n fast multiscale clustering of %s\n',mineral);
fprintf('   %d pixels, noise %.3g degree\n',numClusters(1), hier.sigma);
fprintf('   %s\n\n',par);

fprintf(' scale   aggregates   gradients   pixels read\n');
fprintf(' ---------------------------------------------\n');

for s = 1:numS

  % the pixels are the bottom of the hierarchy: nothing is fitted to a
  % single pixel and nothing is read off below the first aggregation
  if s == 1
    fprintf(' %5d   %10d   %9s   %11s\n',s,numClusters(s),'-','-');
  else
    fprintf(' %5d   %10d   %9d   %11d\n', ...
      s,numClusters(s),hier.nLin(s),intp.readPerScale(s));
  end

end

% a pixel whose interpolation weight was zeroed is read off at no scale
if intp.numStranded > 0
  fprintf('\n %d pixels read off at no scale\n',intp.numStranded);
end

fprintf('\n %d regions -> %d grains', intp.numRegions, intp.numGrains);
if intp.numAbsorbed > 0
  fprintf(', %d pixels absorbed into a neighbour', intp.numAbsorbed);
end
if intp.numUnassigned > 0
  fprintf(', %d left unassigned', intp.numUnassigned);
end
fprintf('\n\n');

end
