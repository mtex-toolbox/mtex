%% Euler Angle Sections
%%
plottingConvention.default("y↑→x");
%%
%
% An ODF is a function on a three dimensional space and cannot be drawn
% directly. The classical way around this is to cut orientation space into
% a stack of two dimensional slices at constant Euler angle and to plot
% those side by side. This page shows the section types MTEX offers and
% what determines the region each of them covers.
%
% As an example we use a model ODF composed of two texture components and a
% fibre.


cs = crystalSymmetry.load('Al-Aluminum.cif')

ori1 = orientation.brass(cs);
ori2 = orientation.copper(cs);
f = fibre.beta(cs);

odf = 0.2*unimodalODF(ori1) + ...
      0.3*unimodalODF(ori2) + ...
      0.5*fibreODF(f)

%%
% Plotting an ODF in two dimensional sections through the orientation space
% is done using the command <SO3Fun.plotSection.html plot>. By default the
% sections are at constant angles of $\varphi_2$. The number of sections
% can be specified by the option |'sections'|

plot(odf,'sections',9,'silent','layout',[5 2])

%%

annotate(ori1,'MarkerSize',15)
annotate(ori2,'Marker','v','MarkerSize',15)

plot(f,'linewidth',2,'add2all')

%%
% One can also specify the $\varphi_2$ angles of the sections explicitly

plot(odf,'phi2',[25 30 35 40]*degree,'silent')

annotate(ori1,'MarkerSize',15)
annotate(ori2,'Marker','v','MarkerSize',15)

plot(f,'linewidth',2,'add2all')

%%
% Beside the standard phi2 sections MTEX supports also sections according
% to all other Euler angles.
%
% * |'phi2'| (default) and |'phi1'|, the first and third Bunge angle
% * |'Phi'|, the second Bunge angle
% * |'gamma'| and |'alpha'|, the Matthies Euler angles
% * |'sigma'|, i.e. $\alpha + \gamma$
%
% The last one is special: along a $\sigma$ section the crystal direction
% that points into the specimen $\vec z$ direction stays fixed, so the
% sections are inverse pole figures of $\vec z$ and no orientation is torn
% apart by the sectioning.

plotSection(odf,'sigma')

%%
% The $\varphi_1$ sections put the specimen direction of a fixed crystal
% direction in the plane instead

plotSection(odf,'phi1','sections',9,'layout',[3 3],'silent')

%%
% and the $\gamma$ sections of the Matthies convention are

plotSection(odf,'gamma','sections',9,'layout',[3 3],'silent')

%%
% All of them accept the same options as the default sections - the number
% of sections, an explicit list of angles, the layout, and any of the
% <PlotTypes.html plot types>. The underlying classes are
% <phi1Sections.html |phi1Sections|>, <phi2Sections.html |phi2Sections|>,
% <sigmaSections.html |sigmaSections|>, <gammaSections.html
% |gammaSections|> and their siblings, and they can also be constructed
% explicitly if a section geometry is to be reused across several plots.

%%
% By default this command represents the ODF in the Bunge Euler angle space
% $\varphi_1$, $\Phi$, $\varphi_2$. The range of the Euler angles depends
% on the crystal symmetry according to the following table
%
% || symmetry     ||    1          ||    2          ||   222         ||    3          ||   32          ||    4          ||   422         ||    6          ||   622         ||    23         ||         432   ||
% || $\varphi_1$  || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ || $360^{\circ}$ ||
% || $\Phi$       || $180^{\circ}$ || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  || $90^{\circ}$  || $90^{\circ}$  ||
% || $\varphi_2$  || $360^{\circ}$ || $180^{\circ}$ || $180^{\circ}$ || $120^{\circ}$ || $120^{\circ}$ || $90^{\circ}$  || $90^{\circ}$  || $60^{\circ}$  || $60^{\circ}$  || $180^{\circ}$ || $90^{\circ}$  ||
%
% Note that for the last two symmetries the three fold axis is not taken
% into account, i.e., each orientation appears three times within the Euler
% angle region. The first Euler angle is not restricted by any crystal
% symmetry, but only by specimen symmetry. For an arbitrary symmetry the
% bounds of the fundamental region can be computed by the command
% <symmetry.fundamentalRegionEuler.html |fundamentalRegionEuler|>
%
%% Specimen Symmetry
%
% As we can see from the above table the first Euler angle $\varphi_1$
% ranges for all symmetries from zero to 360 degree. The only way to
% restrict this angle is to consider specimen symmetry. In the classical
% case of orthotropic specimen symmetry the range of the first Euler angle
% reduces to 90 degree and we obtain the common square shaped ODF section
% plots

odf.SS = specimenSymmetry('222');

plot(odf,'sections',18,'layout',[5 4],...
  'coordinates','off','xlabel','','ylabel','')

