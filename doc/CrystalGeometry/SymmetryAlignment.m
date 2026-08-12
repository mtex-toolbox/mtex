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
% exactly the deviation of $\beta$ from a right angle

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
%% Switching between different Alignment Options
%
% Since, especially for lower symmetry groups, different conventions for
% aligning the crystal axes are used it might be necessary to transform
% data, e.g, orientations or tensors, from one convention into another.
% This can be done using the command <tensor.transformReferenceFrame.html
% transformReferenceFrame> as it illustrated below.
%
% First we import the stiffness tensor Forsterite with respect to the axes
% alignment

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

% import some stiffness tensor
fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');
C = stiffnessTensor.load(fname,cs)

plot(C)

%%
% Let us now consider a different setup of the Forsterite symmetry, where
% the $\vec a$ axis is the longest and the $\vec c$-axis is the shortest.

cs_new = crystalSymmetry('mmm',[10.2296 5.9942 4.7646],'mineral','Olivin')

%%
% In order to represent the stiffness tensor |C| with respect to this
% setup we use the command <tensor.transformReferenceFrame.html
% transformReferenceFrame>.

C_new = C.transformReferenceFrame(cs_new)

nextAxis
plot(C_new)
