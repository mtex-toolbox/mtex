%% Alignment of the Crystal Axes
%%
plottingConvention.default("y↑→x");
%%
%
% A crystal lattice is described by its lattice parameters $a$, $b$, $c$
% and the angles $\alpha$, $\beta$, $\gamma$ between the axes. These fix
% the lattice, but they do not say how it is placed inside the Cartesian
% coordinate system that MTEX computes in - and for anything but the cubic
% case there is more than one common choice.
%
% Unless told otherwise, MTEX uses
%
% * $\vec z \parallel \vec c$ - the $\vec c$ axis, i.e. the axis of highest
% symmetry, points along $\vec z$
% * $\vec x \parallel \vec a^*$ - the $\vec x$ direction is aligned with the
% reciprocal axis $\vec a^*$
%
% The reference frame is printed with every crystal symmetry

cs = crystalSymmetry('12/m1',[4 5 6],[90 100 90]*degree,'mineral','test')

%%
% Note that $\vec a^*$, not $\vec a$, is the direction placed along $\vec
% x$. For a monoclinic lattice with $\beta = 100^\circ$ the two differ by
% exactly the deviation of $\beta$ from a right angle - ten degrees here,
% which is how far the direct axis $\vec a$ sits from $\vec x$ while
% $\vec a^*$ sits on it.

[angle(cs.aAxis,vector3d.X), angle(cs.aAxisRec,vector3d.X)] ./ degree

%%
% For orthogonal lattices - orthorhombic, tetragonal and cubic - the direct
% and the reciprocal axes coincide and the distinction is immaterial. It
% matters for triclinic, monoclinic, trigonal and hexagonal symmetries,
% which is exactly where the competing conventions live.
%
% A different alignment is requested by naming it in the constructor, e.g.

cs2 = crystalSymmetry('12/m1',[4 5 6],[90 100 90]*degree,'X||a','mineral','test')

%%
% The two describe the same crystal, but Miller indices, Euler angles and
% tensor components refer to different Cartesian frames and are therefore
% *not* interchangeable between them.
%
%% Switching Between Alignments
%
% Data published under one convention has to be transformed before it can
% be used under another, and
% <tensor.transformReferenceFrame.html |transformReferenceFrame|> is what
% does it - for tensors as for
% <orientation.transformReferenceFrame.html orientations>. Take a
% published stiffness tensor of olivine, given for the standard setup

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

% import some stiffness tensor
fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');
C = stiffnessTensor.load(fname,cs)

plot(C)

%%
% The plot is the directional stiffness: the crystal is stiffest along the
% short $\vec a$ axis. Another setup of the same mineral names the axes the
% other way round, with $\vec a$ the longest and $\vec c$ the shortest.

cs_new = crystalSymmetry('mmm',[10.2296 5.9942 4.7646],'mineral','Olivin')

%%
% Expressing the same tensor in that setup permutes its components.

C_new = C.transformReferenceFrame(cs_new)

nextAxis
plot(C_new)

%%
% The two plots show the same physical crystal - the stiff direction has
% not moved in the material, only the axis it is called. What would be
% wrong is to use the published numbers unchanged with |cs_new|: that
% describes a crystal whose stiff direction points somewhere else.

%% Next
%
% How the Cartesian frame is inscribed into the crystal axes, and what
% depends on it, is <CrystalReferenceSystem.html The Crystal Reference
% System>. Directions written in the crystal frame are
% <CrystalDirections.html Miller Indices>.
