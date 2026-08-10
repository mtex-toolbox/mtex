%% Export
%
% Every MTEX figure is an ordinary MATLAB figure and can therefore be
% exported with *File / Save As* from the figure menu, or with the MATLAB
% commands |print| and |exportgraphics|. Doing so, however, usually leaves
% a broad white margin around the plot, and for spatial EBSD maps it
% interpolates between neighbouring pixels, which invents colors that are
% not in the data. For this reason MTEX comes with its own command
% <saveFigure.html |saveFigure|>, which is meant to produce cropped,
% publication ready files.
%
%% The command saveFigure
%
% Let us start with any plot

mtexdata forsterite silent

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations)

%%
% The output format of <saveFigure.html |saveFigure|> is determined
% entirely by the file extension. Everything MATLAB can print is allowed -
% |pdf|, |eps|, |ps| for vector graphics and |png|, |jpg|, |tif|, |gif|,
% |bmp| for bitmaps.

% we write into the temporary folder to not pollute the MTEX folder
outFile = fullfile(tempdir,'forsterite.png');

saveFigure(outFile)

%%
% and indeed the file has been written

dir(outFile)

%% Vector graphics versus bitmaps
%
% The two groups of formats are treated quite differently.
%
% *Vector formats* (|pdf|, |eps|, |ps|) are written by |print|. Before
% printing, |saveFigure| sets the paper size to the size of the figure, so
% that the resulting page is exactly as large as the plot and carries no
% margin. If the figure is not in painters mode it is switched over, since
% only painters mode produces true vector output. Note that a spatial EBSD
% map with one patch per pixel becomes a very large file in a vector
% format - for maps a bitmap is usually the better choice.
%
% *Bitmap formats* are written by |export_fig|, at 1.5 times the screen
% resolution. On a spatial map plot MTEX increases this to 2.5 and switches
% graphics smoothing off, so that no colors appear in the image that are
% not in the map itself. This matters as soon as the image is used to read
% back orientations by their color.
%
% Two options are passed on to the underlying tools
%
% * |'crop'| runs |pdfcrop| on the result, removing whatever margin is left
% * |'pdf'| converts an |eps| file to |pdf| using |epstopdf| and crops it
%
% Both shell out to a TeX distribution and are therefore only available on
% Unix like systems.
%
%% Controlling the size of the output
%
% The resolution of a bitmap follows the size of the figure on screen.
% Hence the way to obtain a larger or smaller image is to ask for a larger
% or smaller figure in the first place, using the option |'figSize'|

plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'figSize','small')

%%
% The recognized values are |'tiny'|, |'small'|, |'normal'|, |'large'| and
% |'huge'|, and they are relative to the screen size. The default is stored
% as an <GeneralConceptsConfiguration.html MTEX preference> and can be
% changed permanently by |setMTEXpref('figSize','large')|.
%
%%
% For a multi plot the size refers to the entire figure, not to the
% individual plots

plotPDF(ebsd('Forsterite').orientations,Miller({1,0,0},{0,1,0},{0,0,1},ebsd('Forsterite').CS),...
  'contourf','figSize','normal')
mtexColorbar

%%

saveFigure(fullfile(tempdir,'pdf.png'))

%% Exporting the data instead of the picture
%
% Quite often what is really wanted is not the picture but the numbers
% behind it. Most MTEX classes therefore have their own export command,
% e.g. <quaternion.export.html |export|> for orientations,
% <PoleFigure.export.html |export|> for pole figure data and
% <SO3Fun.export.html |export|> for ODFs. Those are described in the
% corresponding chapters.

% clean up
delete(fullfile(tempdir,'forsterite.png'))
delete(fullfile(tempdir,'pdf.png'))
