function odf = doEulerStep(spin,odf,numIter)

if nargin == 2, numIter = 1; end

if isa(odf,'orientation')

  progress(0,numIter);
  for n = 1:numIter

    % the local gradient
    if isa(spin,'SO3VectorField')
      tv = spin.eval(odf) ./ numIter;
    else
      tv = spin(odf) ./ numIter;
    end

    % rotate the individual orientations
    % this coincides with the ODF version below
    odf = exp(tv, odf);

    % this coincides with the discrete taylor route
    %odf = odf .* orientation(-tv);

    progress(n,numIter);

  end
else

  for n = 1:numIter
    progress(n,numIter)
    odf = odf - div(odf .* spin) ./ numIter;
  end

end


end

