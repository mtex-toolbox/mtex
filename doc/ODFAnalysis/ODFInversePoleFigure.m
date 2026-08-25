%% Inverse Pole Figures of an ODF
%
%%
% An <ODFPoleFigure.html pole figure> fixes a crystal direction and asks
% where in the specimen it points. An *inverse* pole figure fixes a specimen
% direction $\vec r$ and asks which crystal directions point along it,
%
% $$ P_{\vec r}(\vec h) = \int_{g \vec h = \vec r} f(g)\, dg. $$
%
% It is the same integral read the other way round, and again a density in
% multiples of a random distribution - not a percentage at a point. Inverse
% pole figures are the natural view when the specimen direction is the
% meaningful one: the sheet normal, the compression axis, the surface an
% EBSD map was measured on.

plottingConvention.default('y↑→x');

%% A Model Texture to Look At
%
% The same three-component texture as on the pole figure page.

cs = crystalSymmetry('32');
mod1 = orientation.byEuler(90*degree,40*degree,110*degree,'ZYZ',cs);
mod2 = orientation.byEuler(50*degree,30*degree,-30*degree,'ZYZ',cs);

odf = 0.2*unimodalODF(mod1) ...
  + 0.3*unimodalODF(mod2) ...
  + 0.5*fibreODF(Miller(0,0,1,cs),vector3d(1,0,0),'halfwidth',10*degree)

%%

% and let us switch to the LaboTex colormap
setMTEXpref('defaultColorMap',LaboTeXColorMap);

%%
% <SO3Fun.plotIPDF.html |plotIPDF|> works exactly as |plotPDF| does, except
% that it takes specimen directions rather than crystal directions.

plotIPDF(odf,[vector3d.X,vector3d.Z])

%%
% The fibre component puts the c-axis along X, so the X plot carries
% density at the $(0001)$ corner of the sector - 2.7 mrd - while the Z plot
% has essentially none there, 0.02 mrd. The maxima sit elsewhere: the two
% single-orientation components are sharper than the fibre and dominate both
% plots, at 7.7 mrd for X and 23 mrd for Z.

%% Antipodal Symmetry
%
% Assuming that a crystal direction and its opposite cannot be told apart
% halves the region that has to be drawn, exactly as for
% <VectorsAxes.html axes>.

plotIPDF(odf,[vector3d.X,vector3d.Z],'antipodal')

%% The Complete Sphere
%
% By default only the <FundamentalSector.html fundamental sector> is drawn,
% since everything outside it is a symmetric copy of something inside. The
% option |'complete'| shows the copies too.

plotIPDF(odf,[vector3d.X,vector3d.Z],'complete','upper')

%%
% The threefold symmetry of the trigonal group is now visible as the
% repetition of the same pattern three times around the c-axis. With
% antipodal symmetry imposed as well:

plotIPDF(odf,[vector3d.X,vector3d.Z],'complete','antipodal','upper')

%%
% Finally, set the default colormap back.

setMTEXpref('defaultColorMap',WhiteJetColorMap);

%% Next
%
% Colouring an EBSD map by where each orientation falls in this sector is
% <EBSDIPFMap.html IPF Maps>. The other projection is
% <ODFPoleFigure.html Pole Figures>, and the sections that show the ODF
% without projecting at all are <SigmaSections.html Sigma Sections>.

%#ok<*NOPTS>
