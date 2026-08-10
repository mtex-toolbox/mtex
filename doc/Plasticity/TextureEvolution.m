%% Texture Evolution
%
%%
% Plastic deformation does not only change the shape of a polycrystal, it
% also rotates its crystals. The <TaylorModel.html Taylor model> tells us,
% for a given strain and a given family of <SlipSystems.html slip systems>,
% by how much a crystal in a given orientation has to rotate. Applying that
% rotation to every orientation of a sample and iterating over small strain
% increments is the simplest possible simulation of texture evolution, and
% that is what this page does.
%
% Two related pages take different routes to the same question - the
% <SingleSlipModel.html single slip model> solves the continuity equation
% for the ODF analytically, and <VPSCImport.html VPSC> results computed
% outside of MTEX can be imported and analyzed here.
%
%% The crystallographic spin
%
% We consider fcc slip and plane strain, i.e. rolling.

cs = crystalSymmetry('432');
sS = symmetrise(slipSystem.fcc(cs))

%%

q = 0;
epsTotal = 0.6 * strainTensor(diag([1 -q -(1-q)]))

%%
% For a single crystal <strainTensor.calcTaylor.html |calcTaylor|> returns,
% besides the Taylor factor, the spin tensor |W| that the crystal
% experiences

ori = orientation.byEuler(0,30*degree,15*degree,cs);

eps1 = 0.01 * strainTensor(diag([1 -q -(1-q)]));

[M,~,W] = calcTaylor(inv(ori) * eps1, sS);

M

%%
% and the updated orientation is obtained by applying it

oriNew = ori .* orientation(-W);

angle(ori,oriNew) ./ degree

%%
% One percent of strain rotates this crystal by about half a degree. Since
% the spin depends on the orientation, the crystals of a polycrystal drift
% apart at different rates and the texture sharpens.
%
%% Iterating over a polycrystal
%
% Evaluating |calcTaylor| separately for every orientation would be far too
% slow. Called without an orientation it instead returns the Taylor factor
% and the spin as <SO3FunConcept.html orientation dependent functions>,
% which are then cheap to evaluate on a whole list of orientations. We
% compute this spin field once, for a single strain increment.

numIter = 60;

[~,~,spin] = calcTaylor(epsTotal ./ numIter, sS)

%%
% Note that this step takes the bulk of the computing time, and its cost
% depends only on the bandwidth of the harmonic representation, not on the
% number of orientations. Passing |'bandwidth',16| makes it noticeably
% faster at the price of a relative error of a few percent in the spin.
%
% We start from a uniform texture

rng(0)
ori = orientation.rand(2e4,cs);

odf0 = calcDensity(ori,'halfwidth',10*degree);

norm(odf0)^2

%%
% and step through the deformation

pC = progressCounter(numIter);
for k = 1:numIter

  % the spin experienced by each individual orientation
  W = spinTensor(spin.eval(ori).').';

  % rotate the orientations
  ori = ori .* orientation(-W);

  pC.show(k);
end

%% The resulting rolling texture

pfAnnotations = @(varargin) text([vector3d.X,vector3d.Y,vector3d.Z],...
  {'RD','TD','ND'},'BackgroundColor','w','tag','axesLabels',varargin{:});
storepfA = getMTEXpref('pfAnnotations');
setMTEXpref('pfAnnotations',pfAnnotations);
plottingConvention.default("y←↑x");

plotPDF(ori,Miller({0,0,1},{1,1,1},cs),'contourf')
mtexColorbar

%%
% The initially uniform texture has developed the familiar fcc rolling
% components. How strong the texture has become is best measured by the
% texture index $\lVert f \rVert^2$

odf = calcDensity(ori,'halfwidth',10*degree);

norm(odf)^2

%%
% For reference, the same computation stopped at 20 and at 40 percent
% strain gives 1.15 and 1.50 - the texture index grows steadily but the
% texture is still far from being sharp at 60 percent.
%
%%

plotSection(odf,'phi2',[0 45 65]*degree,'contourf')
mtexColorbar

%% Things worth knowing
%
% * The step size matters. The spin field is computed for one strain
% increment and then applied |numIter| times, which is an explicit Euler
% scheme - too few steps and the trajectories are wrong, too many and the
% computation is needlessly slow.
% * The model deforms every crystal by exactly the same strain, which is
% the defining Taylor assumption. It over predicts the sharpness of real
% textures, because in a real material grains accommodate each other.
% * Nothing here depends on the strain being plane strain. Changing
% |epsTotal| to |strainTensor(diag([-0.5 -0.5 1]))| gives axisymmetric
% tension, and the same loop produces the corresponding fibre texture.
% * The slip systems enter only through |sS|. Replacing
% |slipSystem.fcc| by |slipSystem.bcc| or by a hexagonal family, see
% <TaylorHex.html Taylor Model for Hexagonal Materials>, changes the
% predicted texture completely.

% restore MTEX preferences
setMTEXpref('pfAnnotations',storepfA);

%#ok<*NOPTS,*ASGLU>
