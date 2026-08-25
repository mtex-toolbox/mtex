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

%%
% <SO3Fun.plotIPDF.html |plotIPDF|> works exactly as |plotPDF| does, except
% that it takes specimen directions rather than crystal directions.

plotIPDF(odf,[vector3d.X,vector3d.Z])
mtexColorMap LaboTeX

%%
% The fibre component puts the c-axis along X, so the $(0001)$ corner is the
% maximum of the X inverse pole figure. The same corner is almost empty for
% Z. These statements can be read from the colours, but evaluating the two
% inverse pole density functions makes them quantitative.

ipdfX = calcPDF(odf,[],vector3d.X);
ipdfZ = calcPDF(odf,[],vector3d.Z);

[ipdfX.eval(cs.cAxis),ipdfZ.eval(cs.cAxis); max(ipdfX),max(ipdfZ)]

%%
% The first row is the density at $(0001)$: about 23 mrd for X and 0.025
% mrd for Z. The second row contains the maxima. For X the c-axis corner is
% itself the maximum; for Z the maximum is about 5.4 mrd elsewhere in the
% sector. This is the distinction an inverse pole figure is good at making:
% it answers which crystal direction prefers one chosen specimen direction.

%% Antipodal Symmetry
%
% Assuming that a crystal direction and its opposite cannot be told apart
% halves the region that has to be drawn, exactly as for
% <VectorsAxes.html axes>.

plotIPDF(odf,[vector3d.X,vector3d.Z],'antipodal')
mtexColorMap LaboTeX

%% The Complete Sphere
%
% By default only the <FundamentalSector.html fundamental sector> is drawn,
% since everything outside it is a symmetric copy of something inside. The
% option |'complete'| shows the copies too.

plotIPDF(odf,[vector3d.X,vector3d.Z],'complete','upper')
mtexColorMap LaboTeX

%%
% The threefold symmetry of the trigonal group is now visible as the
% repetition of the same pattern three times around the c-axis. With
% antipodal symmetry imposed as well:

plotIPDF(odf,[vector3d.X,vector3d.Z],'complete','antipodal','upper')
mtexColorMap LaboTeX

%% Next
%
% Colouring an EBSD map by where each orientation falls in this sector is
% <EBSDIPFMap.html IPF Maps>. The other projection is
% <ODFPoleFigure.html Pole Figures>, and the sections that show the ODF
% without projecting at all are <SigmaSections.html Sigma Sections>.

%#ok<*NOPTS>
