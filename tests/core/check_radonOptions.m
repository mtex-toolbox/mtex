function check_radonOptions
% check that radon accepts an option in the position of r
%
% radon's signature is radon(SO3F,h,r,varargin), so a third positional
% argument that is an option string used to bind to r and reach dot_outer as
% "Dot indexing is not supported for variables of this type". The workaround
% was radon(odf,h,[],'bandwidth',64). Every implementation was affected -
% @SO3Fun, @SO3FunRBF, @SO3FunCBF, @SO3FunBingham, @SO3FunHarmonic - so all
% of them are checked here, together with the positional syntax that has to
% keep working.
%
% Also checks that @SO3FunComposition/radon decides the antipodal flag of
% its result itself instead of inheriting whatever its components happened
% to set.

rng(0)

cs = crystalSymmetry('432');
h = Miller(1,0,0,cs);
r = vector3d.rand(7);

odfs = odfZoo(cs);

for k = 1:2:numel(odfs)
  checkOptionInPositionOfR(odfs{k},odfs{k+1},h);
  checkPositionalR(odfs{k},odfs{k+1},h,r);
end

checkCompositionAntipodal(cs,h);

disp('check_radonOptions: passed');

end

% =========================================================================
function odfs = odfZoo(cs)
% one ODF of every type that implements radon

odfs = { ...
  'SO3FunRBF', unimodalODF(orientation.rand(cs)), ...
  'SO3FunHarmonic', SO3FunHarmonic(unimodalODF(orientation.rand(cs))), ...
  'SO3FunCBF', fibreODF(fibre.rand(cs)), ...
  'SO3FunBingham', SO3FunBingham([10 5 1 0],orientation.rand(4,cs)), ...
  'SO3FunHandle', SO3FunHandle(@(ori) 1 + cos(angle(ori)),cs), ...
  'SO3FunComposition', 0.5*unimodalODF(orientation.rand(cs)) + ...
  0.5*fibreODF(fibre.rand(cs))};

end

% -------------------------------------------------------------------------
function checkOptionInPositionOfR(name,SO3F,h)
% radon(SO3F,h,'bandwidth',16) has to do what radon(SO3F,h,[],'bandwidth',16)
% does, not throw

try
  S2F = radon(SO3F,h,'bandwidth',16);
catch e
  error('check_radonOptions: radon(%s,h,''bandwidth'',16) throws: %s',name,e.message)
end

ref = radon(SO3F,h,[],'bandwidth',16);

assert(strcmp(class(S2F),class(ref)), ...
  'check_radonOptions: %s returns a %s with the option shifted and a %s without', ...
  name, class(S2F), class(ref))

% same function, i.e. the option really arrived as an option
v = vector3d.rand(20);
assert(max(abs(eval(S2F,v) - eval(ref,v))) < 1e-10, ...
  'check_radonOptions: %s gives a different result with and without the explicit []', name)

% the option is honoured rather than swallowed. A representation may not be
% able to give more than it has - @SO3FunHarmonic and @SO3FunRBF cap the
% request at their own bandwidth - but it must not give more than asked for
low = radon(SO3F,h,'bandwidth',4);
assert(low.bandwidth <= 4, ...
  'check_radonOptions: %s ignores the shifted bandwidth, it is %d instead of 4', ...
  name, low.bandwidth)

end

% -------------------------------------------------------------------------
function checkPositionalR(name,SO3F,h,r)
% the positional syntaxes still mean what they meant

v = radon(SO3F,h,r);
assert(isnumeric(v) && numel(v) == length(r), ...
  'check_radonOptions: %s with both h and r returns a %s of %d values, expected %d doubles', ...
  name, class(v), numel(v), length(r))

S2F = radon(SO3F,[],r(1));
assert(isa(S2F,'S2Fun'), ...
  'check_radonOptions: %s with an empty h returns a %s instead of an S2Fun', ...
  name, class(S2F))

end

% -------------------------------------------------------------------------
function checkCompositionAntipodal(cs,h)
% @SO3FunComposition/radon only sums its components, so it used to be
% antipodal only if every single component happened to set the flag - there
% was no safety net for a component type that does not, which is exactly
% what @SO3FunCBF was until 2026-08-06.

% a Laue group makes every pole figure even
csLaue = crystalSymmetry('m-3m');
assert(csLaue.isLaue,'check_radonOptions: m-3m is expected to be a Laue group')

odf = 0.5*unimodalODF(orientation.rand(csLaue)) + 0.5*fibreODF(fibre.rand(csLaue));

S2F = radon(odf,Miller(1,0,0,csLaue),'bandwidth',16);
assert(S2F.antipodal, ...
  'check_radonOptions: the radon transform of a composition over a Laue group is not antipodal')

% and so does an antipodal h, over a group that is not Laue
assert(~cs.isLaue,'check_radonOptions: this check needs a group that is not Laue')

odf = 0.5*unimodalODF(orientation.rand(cs)) + 0.5*fibreODF(fibre.rand(cs));

h.antipodal = true;
S2F = radon(odf,h,'bandwidth',16);
assert(S2F.antipodal, ...
  'check_radonOptions: an antipodal h does not make the composition radon transform antipodal')

end
