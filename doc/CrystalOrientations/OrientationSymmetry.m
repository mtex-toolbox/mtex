%% Symmetrically Equivalent Orientations
%
%%
% A crystal orientation always appears as a class of symmetrically
% equivalent rotations which all transform the crystal reference frame into
% the specimen reference frame and are physically not distinguishable. 
%
% Lets start by defining some random orientation

% trigonal crystal symmetry
cs = crystalSymmetry('6')

% monoclinic specimen symmetry with respect to the x-axis
ss = specimenSymmetry('112')

% a random orientation
ori = orientation.rand(cs,ss)


%%
% Since orientations transform crystal coordinates into specimen
% coordinates crystal symmetries will act from the right and specimen
% symmetries from the left

% symmetrically equivalent orientations with respect to crystal symmetry
ori * cs

%%
% We observe that only the third Euler angle phi2 changes as this Euler
% angle applies first to the crystal coordinates.

% symmetrically equivalent orientations with respect to specimen symmetry
ss * ori

%%
% Combining crystal and specimen symmetry we obtain 6 crystallographically
% equivalent orientations to |ori|

ss * ori * cs

%%
% A shortcut for this operation is the command <orientation.symmetrise.html
% symmetrise>

symmetrise(ori)

%%
% The consequence is visible in any pole figure. One orientation and one
% crystal direction give not one pole but a whole set of them, because the
% lattice cannot tell its symmetrically equivalent settings apart.

h = Miller(1,0,0,cs);

plotPDF(ori,h,'MarkerSize',10,'figSize','small')

%%
% Every dot is the same physical direction of the same crystal. Which of
% them you happen to compute is an accident of how the orientation was
% written down, which is why every comparison in MTEX takes all of them into
% account.
%
%%
% For specific orientations, e.g. for the cube orientations, symmetrisation
% leads to multiple identical orientations. This can be prevented by
% passing the option |unique| to the command <orientation.symmetrise.html
% symmetrise>

symmetrise(orientation.id(cs,ss),'unique')

%% Crystal symmetries in computations
%
% Note that all operation on orientations are preformed taking all
% symmetrically equivalent orientations into account. As an example
% consider the angle between a random orientation and all orientations
% symmetrically equivalent to the goss orientation

ori = orientation.rand(cs);
angle(ori,symmetrise(orientation.goss(cs))) ./ degree

%%
% The value is the same for all orientations and equal to the smallest
% angle to one of the symmetrically equivalent orientations. This can be
% verified by computing the rotational angle ignoring symmetry.

angle(ori,symmetrise(orientation.goss(cs)),'noSymmetry') ./ degree

%%
% Functions that respect crystal symmetry but allow to switch it off using
% the flag |noSymmetry| include <orientation.dot.html dot>,
% <orientation.unique.html unique>, <orientation.calcCluster.html
% calcCluster>.
