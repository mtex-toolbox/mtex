function vF = sigma

vF = S2VectorFieldHandle(@(r) local(r));

  function v = local(r)
    [theta,rho] = polar(r); %#ok<POLAR>
    rot = rotation.byEuler(rho,theta,-rho,'ZYZ');
    v = rot .* xvector;
  end

end
