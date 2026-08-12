function check_homochoric
% check rotation.byHomochoric against quaternion/homochoric
%
% Note on tolerances: angle(rot1,rot2) goes through acos near 1 and therefore
% floors out around sqrt(eps) - angle(rot,rot) alone already reports up to
% 6e-8. Accuracy is thus measured by quaternion distance and by the
% homochoric vectors themselves, never by angle().

rng(0)

R = (0.75*pi)^(1/3);   % radius of the homochoric ball, omega = pi

% --- roundtrip rotation -> homochoric -> rotation
rot  = rotation.rand(20000);
rot2 = rotation.byHomochoric(rot.homochoric);
dq = min(norm(rot-rot2), norm(rot+rot2));
assert(max(dq) < 1e-13, 'rot->v->rot roundtrip: max quaternion distance %.3e', max(dq))

% --- roundtrip homochoric -> rotation -> homochoric, covering the whole ball
v = vector3d.rand(20000) .* (R * rand(20000,1).^(1/3));
e = norm(v - rotation.byHomochoric(v).homochoric);
assert(max(e) < 1e-13, 'v->rot->v roundtrip: max %.3e', max(e))

% --- the identity: rho = 0 leaves the rotational axis undefined
id = rotation.byHomochoric(vector3d(0,0,0));
assert(~isnan(id.a), 'byHomochoric(0) must not be NaN')
assert(min(norm(id-rotation.id),norm(id+rotation.id)) < 1e-15, 'byHomochoric(0) must be the identity')

% --- the ball surface maps onto omega = pi
assert(max(abs(angle(rotation.byHomochoric(R*vector3d.rand(1000))) - pi)) < 1e-12, ...
  'the ball surface must map onto omega = pi')

% --- small angles, where omega - sin(omega) cancels catastrophically if
%     evaluated directly. Compare against rho built analytically by series.
om = 10.^(-linspace(7,1,4000))';
w2 = om.^2;
rho = (0.75 * om.^3/6 .* (1 - w2/20 .* (1 - w2/42 .* (1 - w2/72)))).^(1/3);
rec = rotation.byHomochoric(rho .* vector3d(1,2,3).normalize);
% Read omega back as 2*asin(|vector part|). Neither angle() nor homochoric()
% can be used here: both recover omega through acos(cos(omega/2)), which for
% omega = 1e-7 has already lost every significant digit, whereas
% sin(omega/2) keeps full relative precision.
omRec = 2*asin(min(norm(vector3d(rec.b,rec.c,rec.d)),1));
assert(max(abs(omRec - om)./om) < 1e-9, ...
  'small angle accuracy: max rel %.3e', max(abs(omRec-om)./om))

% --- monotonicity: rho must increase strictly with omega
omg = linspace(0,pi,2000)';
assert(all(diff(norm(rotation.byAxisAngle(zvector,omg).homochoric)) > 0), ...
  'rho must be strictly increasing in omega')

% --- input forms and shape
assert(isequal(size(rotation.byHomochoric(vector3d.rand(4,5))),[4 5]), 'shape not preserved')
assert(min(norm(rotation.byHomochoric([0.1 0.2 0.3]) - rotation.byHomochoric(vector3d(0.1,0.2,0.3))), ...
  norm(rotation.byHomochoric([0.1 0.2 0.3]) + rotation.byHomochoric(vector3d(0.1,0.2,0.3)))) < 1e-15, ...
  'numeric input must match vector3d input')
assert(isempty(rotation.byHomochoric(vector3d.rand(0,1))), 'empty input')

disp('check_homochoric passed')
end
