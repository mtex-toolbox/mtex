function odf = doEulerStep(spin,odf,numIter)
% numericaly solve the continuity equation with a given spin tensor
%
% Syntax
%
%   odf_n = doEulerStep(spin,odf_0,numIter)
%
%   ori_n = doEulerStep(spin,ori_0,numIter)
%
% Input
%  spin    - @SO3VectorField, orientation dependent spin tensor
%  odf_0   - @SO3Fun, initial ODF
%  ori_0   - @orientation, initial list of orientations
%  numIter - number of iterations
%
% Output
%  odf_n   - @SO3Fun, ODF after numIter iteration steps
%  ori_n   - @orientation, orientations after numIter iteration steps
%
% See also
% SingleSlipModel, Taylormodel, SO3Fun/div, strainTensor/calcTaylor
%

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

