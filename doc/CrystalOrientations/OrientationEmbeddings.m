%% Embeddings of Orientations
%
%%
% An orientation embedding represents each physical orientation by a unique
% tensor in a Euclidean space. Symmetrically equivalent rotations therefore
% have the same embedding. This makes ordinary linear operations available
% without first choosing one rotation from each equivalence class.
%
% This page assumes the symmetry equivalence developed in
% <OrientationSymmetry.html Orientation Symmetry> and the representative
% selection explained in
% <OrientationFundamentalRegion.html Fundamental Regions>. The
% <MisorientationTheory.html misorientation angle> supplies the intrinsic
% distance used below.
%
%% Why Fundamental-Region Coordinates Jump
%
% A rotation matrix is a tensorial representation of a rotation, but it is
% not a unique representation of an orientation with crystal symmetry.
% Restricting rotations to a fundamental region selects one representative
% from each equivalence class. Near the boundary, however, two nearby
% orientations can be assigned representatives on opposite sides of the
% region. Their coordinate vectors are then far apart even though their
% misorientation angle is small.
%
% The following experiment compares three distances for random pairs of
% cubic orientations.

% cubic proper rotation symmetry
cs = crystalSymmetry('432');

% select representatives in the fundamental region
ori1 = project2FundamentalRegion(orientation.rand(20000,cs));
ori2 = project2FundamentalRegion(orientation.rand(20000,cs));

% intrinsic misorientation angle in degrees
omega = angle(ori1,ori2) ./ degree;

% Euclidean distances between matrix and Rodrigues representatives
distMat = norm(tensor(ori1) - tensor(ori2));
distRV = norm(Rodrigues(ori1) - Rodrigues(ori2));

figure('position',[200 200 1200 400])
subplot(1,3,1)
scatter(omega,distMat,3,'.')
xlabel('$\omega(\mathtt{ori}_1,\mathtt{ori}_2)$ in degrees',...
  'Interpreter','latex')
ylabel('$\Vert\mathtt{tensor(ori_1)}-\mathtt{tensor(ori_2)}\Vert_2$',...
  'Interpreter','latex')
title('rotation matrices')

subplot(1,3,2)
scatter(omega,distRV,3,'.')
xlabel('$\omega(\mathtt{ori}_1,\mathtt{ori}_2)$ in degrees',...
  'Interpreter','latex')
ylabel('$\Vert\mathtt{R(ori_1)}-\mathtt{R(ori_2)}\Vert_2$',...
  'Interpreter','latex')
title('Rodrigues vectors')

subplot(1,3,3)
scatter(distMat,distRV,3,'.')
xlabel('$\Vert\mathtt{tensor(ori_1)}-\mathtt{tensor(ori_2)}\Vert_2$',...
  'Interpreter','latex')
ylabel('$\Vert\mathtt{R(ori_1)}-\mathtt{R(ori_2)}\Vert_2$',...
  'Interpreter','latex')
title('two coordinate distances')

%%
% In the first two panels, points near the left edge can still have a large
% coordinate distance. The third panel shows that matrix and
% <rotation.byRodrigues.html Rodrigues Frank> coordinates jump differently.
% Neither Euclidean coordinate distance is the geometry of orientation
% space.
%
% This is why averaging fundamental-region coordinates is unsafe. Consider
% the orientations with Bunge Euler angles
% $(44^{\circ},0^{\circ},0^{\circ})$ and
% $(46^{\circ},0^{\circ},0^{\circ})$.

ori = project2FundamentalRegion(...
  orientation.byEuler([44 46]*degree,0,0,cs));

% average the selected Rodrigues representatives
naiveMean = orientation.byRodrigues(mean(ori.Rodrigues),cs)

%%
% The displayed result is the identity orientation. It is $45^{\circ}$
% from the expected mean because the two selected Rodrigues vectors lie on
% opposite sides of a fundamental-region boundary. In contrast,
% <orientation.mean.html |mean|> handles crystal symmetry.

intrinsicMean = mean(ori)

%%
% The symmetry-aware mean is the physical orientation represented by
% $(45^{\circ},0^{\circ},0^{\circ})$. More generally, this coordinate jump
% affects any vector-space method applied directly to fundamental-region
% matrices, Rodrigues vectors, or Euler angles.
%
%% Constructing an Embedding
%
% The @embedding class replaces a chosen coordinate representative by a
% higher-dimensional tensor that is invariant under the crystal symmetry.
% Its Euclidean metric is locally isometric to the misorientation metric.
% It therefore agrees with the misorientation angle for small separations,
% but its chord distance is not the geodesic distance for arbitrary pairs.

e1 = embedding(ori1);
e2 = embedding(ori2)

%%
% The summary identifies the cubic symmetry, tensor rank, packed dimension,
% and number of embedded orientations. This output is useful because the
% required tensor rank and dimension depend on the crystal symmetry.
%
% Compare the Euclidean embedding distance with the misorientation angle.
% Division by |degree| expresses the locally isometric distance in degrees.

distE = norm(e1-e2) ./ degree;

close all
scatter(omega,distE,3,'.')
xlabel('$\omega(\mathtt{ori}_1,\mathtt{ori}_2)$ in degrees',...
  'Interpreter','latex')
ylabel('$\Vert\mathcal E(\mathtt{ori}_1)-\mathcal E(\mathtt{ori}_2)\Vert_2$',...
  'Interpreter','latex')

%%
% Near the origin the point cloud follows the diagonal: embedding distance
% closely approximates the misorientation angle. The increasing curvature
% at larger angles is the difference between an ambient chord and a
% geodesic on orientation space.
%
%% Averaging in Embedding Space
%
% An arithmetic mean of embeddings lies in the ambient Euclidean space and
% generally is not itself the embedding of an orientation. Project it back
% with <embedding.orientation.html |orientation|>.

e = embedding(ori);
meanEmbedding = mean(e);
embeddingMean = orientation(meanEmbedding)

%%
% MTEX may print this cubic orientation with Euler angle $315^{\circ}$
% instead of $45^{\circ}$. Those are symmetry-equivalent representatives,
% not different physical means. The intrinsic angular error confirms the
% result.

targetMean = orientation.byEuler(45*degree,0,0,cs);
embeddingMeanError = angle(embeddingMean,targetMean) ./ degree

%% Constant Norm and Dispersion
%
% All orientations of one symmetry have the same embedding norm. The raw
% radius depends on the symmetry; the |'normalized'| option divides by that
% radius. The following output is therefore a row of ones.

normalizedNorms = norm(embedding(orientation.rand(5,cs)),...
  'normalized').'

%%
% Normalized embeddings lie on the unit sphere. Their arithmetic mean lies
% inside the unit ball, so its norm can summarize concentration. A value
% close to one indicates a tight cluster. A value near zero indicates
% strong cancellation; it can accompany orientations far apart in the
% orientation space, but does not by itself prove that a maximally separated
% pair is present.
%
% Write the normalized mean-embedding norm as
%
% $$ n=\frac{1}{\rho}\left\Vert\frac{1}{N}\sum_{i=1}^N
% \mathcal E(\mathtt{ori}_i)\right\Vert, \qquad
% \rho=\Vert\mathcal E(\mathtt{ori})\Vert.$$
%
% Compare it with the angular standard deviation
%
% $$ \sigma=\left(\frac{1}{N}\sum_{i=1}^N
% \omega(\mathtt{ori}_i,\mathtt{mori})^2\right)^{1/2},$$
%
% where $\mathtt{mori}$ is the mean orientation. The first samples come
% from one family of <RadialODFs.html#3 unimodal de la Vallee Poussin
% distributions> with varying halfwidth.

n = []; sigma = [];
for hw = logspace(-1,1.75,40)*degree

  psi = SO3DeLaValleePoussinKernel('halfwidth',hw);
  odf = unimodalODF(orientation.rand(cs),psi);
  ori = discreteSample(odf,round(1000*(hw*6)^3));

  n(end+1) = norm(mean(embedding(ori)),'normalized');
  sigma(end+1) = std(ori);

end

plot(sigma,sqrt(max(0,1-n)),'linewidth',2)
xlabel('standard deviation $\sigma$','Interpreter','latex')
ylabel('$\sqrt{1-n}$','Interpreter','latex')

%%
% The smooth curve can suggest that the mean-embedding norm determines the
% standard deviation. That apparent relationship comes from varying only
% one distribution family. <BinghamODFs.html Bingham distributions> form a
% broader family and expose the ambiguity.

n = []; sigma = [];
for k = 1:2:600

  kappa = rand(4,1);
  kappa = k * kappa ./ sum(kappa);
  odf = BinghamODF(kappa,cs);
  ori = discreteSample(odf,1000);

  n(end+1) = norm(mean(embedding(ori)),'normalized');
  sigma(end+1) = std(ori);

end

hold on
scatter(sigma,sqrt(max(0,1-n)),12,'filled')
legend('de la Vallee Poussin','Bingham','Location','best')
hold off

%%
% The Bingham points do not collapse onto the first curve. Thus the norm of
% the mean embedding is a concentration summary, not a one-to-one proxy for
% angular standard deviation. The figure is also a warning against
% calibrating one dispersion measure from a single distribution family.
%
%% Operations
%
% Embeddings support the following linear-space operations:
%
% * <embedding.plus.html |+|>, <embedding.minus.html |-|>,
% <embedding.mtimes.html |*|>, <embedding.times.html |.*|>, and
% <embedding.rdivide.html |./|>
% * <embedding.sum.html |sum|> and <embedding.mean.html |mean|>
% * <embedding.norm.html |norm|> and
% <embedding.normalize.html |normalize|>
% * <embedding.dot.html |dot|>
% * <embedding.rotate.html |rotate|> and
% <embedding.rotate_outer.html |rotate_outer|>
%
%% Packed Numeric Coordinates
%
% The tensor representation stores repeated components. The
% <embedding.double.html |double|> method packs the independent components
% into a numeric matrix while preserving Euclidean distances exactly. For
% cubic symmetry the following output compares the full tensor component
% count with the packed dimension.

fullDimension = size(double(e1,'full'),2)
packedDimension = size(double(e1),2)

%%
% Each row of the packed matrix now represents one orientation and can be
% passed to numerical or machine-learning code. This packing is not a
% learned dimensionality reduction, and an arbitrary row in the ambient
% space need not correspond to a valid orientation.

distD = vecnorm(double(e1) - double(e2),2,2) ./ degree;
packingError = max(abs(distE-distD))

close all
scatter(omega,distD,3,'.')
xlabel('$\omega(\mathtt{ori}_1,\mathtt{ori}_2)$ in degrees',...
  'Interpreter','latex')
ylabel('$\Vert\mathtt{double}(\mathcal E_1)-\mathtt{double}(\mathcal E_2)\Vert_2$',...
  'Interpreter','latex')

%%
% This plot reproduces the earlier embedding-distance plot, and the printed
% packing error is at floating-point roundoff. Packing removes redundant
% tensor entries without changing the metric.
%
%% References
%
% * R. Arnold, P. E. Jupp and H. Schaeben,
% <https://doi.org/10.1016/j.jmva.2017.10.007 Statistics of ambiguous
% rotations>, _Journal of Multivariate Analysis_ 165, 73--85, 2018.
% * R. Hielscher and L. Lippert,
% <https://doi.org/10.1016/j.jmva.2021.104764 Locally isometric embeddings
% of quotients of the rotation group modulo finite symmetries>, _Journal of
% Multivariate Analysis_ 185, 104764, 2021.
% * M. Moakher,
% <https://doi.org/10.1137/S0895479801383877 Means and averaging in the
% group of rotations>, _SIAM Journal on Matrix Analysis and Applications_
% 24, 1--16, 2002.
% * K. V. Mardia and P. E. Jupp,
% <https://doi.org/10.1002/9780470316979 Directional Statistics>, Wiley,
% 2000, gives the broader statistical background for directional data.
%
%% Next
%
% Continue with <Misorientations.html Misorientations> to study relative
% orientations and their symmetry. For distributions of whole orientation
% populations, continue with <ODFAnalysis.html Orientation Density
% Functions>.

%#ok<*SAGROW>
