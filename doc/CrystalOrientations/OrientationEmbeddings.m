%% Embeddings of Orientations
%
%%
% Orientational embeddings are tensorial representations of orientations
% with the specific property that each class of symmetrically equivalent
% orientations has a unique tensor representation. The easiest tensorial
% representation of a rotation is its rotational matrix. However, in the
% presense of crystal symmetry multiple rotational matrices describe the
% same orientation. This can be avoided by restricting the space of
% admissible matrices to the so called fundamental region. However, this
% creates the problem that two similar orientations may be represented by
% very different matrices in the fundamental region. This ussualy happens
% if the orientations are close to the boundary of the fundamental region.
%
% The central problem is that the geometry of the fundamental region is not
% the geometry of the orientation space. Lets demonstate this by taking
% pairs of random orientations in the fundamental region and compare their
% misorientation angle with the Euclidean distance of the corresponding
% rotational matrices and the corresponding Rodrigues Frank vectors.

% consider cubic symmetry
cs = crystalSymmetry('432');

% random pairs of orientations in the fundamental sector
ori1 = project2FundamentalRegion(orientation.rand(100000,cs));
ori2 = project2FundamentalRegion(orientation.rand(100000,cs));

% compute the misorienation angles in degree
omega = angle(ori1,ori2)./degree;

% compute the Euclidean distance between the rotational matrices
distMat = norm(tensor(ori1) - tensor(ori2));

% compute the Euclidean distance between the Rodrigues Frank vectors
distRV = norm(Rodrigues(ori1) - Rodrigues(ori2));

% plot 
figure('position',[200 200 1200 400 ])
subplot(1,3,1)
scatter(omega,distMat)
xlabel('misorientation angle $\omega(\mathtt{ori}_1,\mathtt{ori}_2)$','Interpreter','latex')
ylabel('matrix distance')

subplot(1,3,2)
scatter(omega,distRV)
xlabel('misorientation angle $\omega(\mathtt{ori}_1,\mathtt{ori}_2)$','Interpreter','latex')
ylabel('Rodrigues distance')

subplot(1,3,3)
scatter(distMat,distRV)
xlabel('misorientation angle $\omega(\mathtt{ori}_1,\mathtt{ori}_2)$','Interpreter','latex')
ylabel('Rodrigues distance')



%%
% We observe that orientations that have very small misorientation angle
% may be very far from each other in Rodrigues Frank space. As a
% consequence, we can not simply compute the average of two orientations by
% taking the mean of the corresponding Rodrigues vectors. Lets have a look
% at an extremal case of finding the mean orientations of the orientations
% (44,0,0) and (46,0,0)

% define two orientations
ori = orientation.byEuler([44 46]*degree,0,0,cs);
ori = ori.project2FundamentalRegion;

%compute the mean by averagin the Rodrigues vectors
mori = orientation.byRodrigues(mean(ori.Rodrigues),cs)

%%
% The  mean orientation computed from the average of the Rodrigues vectors
% is (0,0,0) is far away from the true mean.

mean(ori)

%%
% This issue does not only apply to the mean but actually to all
% statistical methods that work well for vectorial data and that one would
% like to apply to orientation data.
%
% The crucial idea of an embedding is to replace the vectorial
% representation by a higher dimensional tensorial representation that
% preserves the geometry and the distances of the orientation space as good
% as possible.
%
%% Defining an embedding
%
% Defining an embedding $\mathcal E(\mathtt{ori})$ of an orientation |ori|
% is done by calling the function |@embedding|.

e1 = embedding(ori1);
e2 = embedding(ori2)

%%
% This creates a variable of type |@embedding| that behaves like list of
% vectors, i.e., variable of type |@embedding| can be summed, rotated,
% scaled and one can compute the inner product between two embeddings. Lets
% have a look at the Euclidean distances between the embeddings |e1| and
% |e2|

% the Euclidean distance in the embedding
distE = norm(e1-e2) ./ degree;

close all
scatter(omega,distE)
xlabel('misorientation angle $\omega(\mathtt{ori}_1,\mathtt{ori}_2)$','Interpreter','latex')
ylabel('embedding distance')

%%
% We observe that the distance in the embedding differs slightly from the
% misorientation angle. However, especially for small misorientation angles
% the approximation is very good.
%
% Lets go back to our second example of averaging the orientations (44,0,0)
% and (46,0,0). If we compute the embedding of both orientations, average
% the resulting tensors and then project to mean tensor back to an
% orientation we end up with the correct result (0,0,0).

% compute the embedding of the two orientations
e = embedding(ori)

% take the mean of the embeddings
me = mean(e);

% computet an orientation from the mean embedding
orientation(me)

%% Basic Properties
%
% By construction the embeddings of all orientations have the same norm.

norm(embedding(orientation.rand(5,cs))).'

%%
% In other words the embeddings are located on the surface of a ball with a
% radius $1$. When computing the mean from a list of embeddings the
% resulting tensor has in general a smaller norm, i.e., is inside this
% ball. Similarly as in spherical statistics the norm of the mean of the
% embeddings can be interpreted as a measure of the dispersion of the
% orientations. If the norm is close to 1 the orientations are tightly
% concentrated around a prefered orientation, whereas if the norm is close
% to zero some of the orientations are at maximum distance to each other.
%%
% Lets compare the norm 
%
% $$ n=\left\lVert\frac{1}{n} \sum_{i=1}^N \mathcal E(\mathtt{ori}_i) \right\rVert$$
% 
% of the mean embedding with the standard deviation 
%
% $$ \sigma = \left(\frac{1}{N} \sum_{i=1}^N \omega(\mathtt{ori}_i,
% \mathtt{mori})^2\right)^{1/2}$$
% 
% where $\omega(\mathtt{ori}_i, \mathtt{mori}))$ denotes the misorientation
% angle between the orientations $\mathtt{ori}_i$ and the mean orientation
% $\mathtt{mori}$.

% genrate samples of orientations of different dispersion
n = []; sigma = [];
for hw = logspace(-1,1.75,40)*degree

  psi = deLaValleePoussinKernel('halfwidth',hw);
  odf = unimodalODF(orientation.rand(cs),psi);
  ori = discreteSample(odf,round(1000*(hw*6)^3));
  
  n(end+1) = norm(mean(embedding(ori)));
  
  sigma(end+1) = std(ori);
  progress(length(sigma),40);
  
end

plot(sigma,real(sqrt(1-n)),'linewidth',2)
xlabel('standard deviation $\sigma$','Interpreter','latex')
ylabel('$\sqrt{1-n}$','Interpreter','latex')

%% 
% It appears as if the norm of the mean embedding is a function of the
% standaerd deviation. However, the reason for this false relationship is
% that we have generated the orientations out of a single family of random
% variables - unimodal de la Vallee Poussin distributed density functions.
% A broader family of density function are the Bingham distributions. Lets
% repeat the experiment for this family.

% genrate ODF of different halfwidth
n = []; sigma = [];
for k = 1:2:600

  kappa = rand(4,1);
  kappa = k * kappa ./sum(kappa);
  odf = BinghamODF(kappa,cs);
  ori = discreteSample(odf,1000);
  
  n(end+1) = norm(mean(embedding(ori)));
  sigma(end+1) = std(ori);
  
end

hold on
scatter(sigma,sqrt(1-n),'linewidth',2)
hold off

%%
% We observe that there is no one-to-one relatioenship between the discrete
% standard deviation. 
%
%% Operations
%
% The following operations are supported for embeddings:
%
% * |+|, |-|, <embedding.mtimes.html |*|>, <embedding.times.html |.*|>, |./| 
% * |sum|, |mean|
% * |norm|, |normalize|
% * |dot|
% * |rotate|, |rotate_outer|
%
%% Rerference
%
% The theory behind these embeddings is explained in the paper
%
% * R. Arnold, P. E. Jupp, H. Schaeben, Statistics of ambiguous rotations,
% Journal of Multivariate Analysis (165), 2018
% * R. Hielscher, L. Lippert, _Isometric Embeddings of Quotients of the
% Rotation Group Modulo Finite Symmetries_,
% <https://arxiv.org/abs/2007.09664 arXiv:2007.09664>, 2020.
%
