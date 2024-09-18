function vF = sigma(varargin)

% extract plotting convention
% we want the singular point to be always at the lower hemisphere
pC = getClass(varargin,'plottingConvention',plottingConvention.default);

vF = S2VectorFieldHandle(@(r) pC.rot .* local(inv(pC.rot) .* r));

  function v = local(r)
    [theta,rho] = polar(r); %#ok<POLAR>
    rot = rotation.byEuler(rho,theta,-rho,'ZYZ');
    v = rot .* xvector;
  end

end
