README

	The Patala colorcode allows one to uniquely idendify a misorientation 
	with a color, for certain crystallographic point groups. This is useful 
	for creating plots of grain boundary networks in which each boundary is
	colored according to its misorientation. What is unique about the Patala
	colorcode is that the color indicates both the misorientation angle AND
	axis. In order to interpret such plots it is necessary to reference a 
	colorbar type legend. This code has been written to incorporate the 
	Patala colorcode into MTEX. It uses, as much as possible, the existing
	functions built into MTEX, and simply extends these capabilities to 
	handle this new coloring scheme. The files included allow the user to
	(1) plot grain boundary maps in which the boundaries are colored according
	to their misorientation, and (2) plot a legend to allow for interpretation
	of the colors in the grain boundary maps. Details regarding installation
	and usage are provided below, and an example file and example data are
	provided to illustrate the features of this package.

INSTALLATION

	To use the Patala colorcode with MTEX place the directory labeled
	'NecessaryFilesPatalaColorCode' inside of the following MTEX directory:

		\mtex-3.4.1\tools\orientationMappings

	This will allow these functions to be available whenever MTEX is 
	running.

	Next, take each file contained in MTEX_ReplacementFiles and replace the
	existing file in the \mtex-3.4.1\... directory that has the same
	name and relative path. For example, take the file called plot.m, which
	is located in:

		\mtex-3.4.1\geometry\@vector3d\

	and replace it with the file called plot.m that is located in:

		\MTEX_ReplacementFiles\geometry\@vector3d\

	Do this for all of the files contained in \MTEX_ReplacementFiles. There
	are a few files in \MTEX_ReplacementFiles that do not have existing 
	versions in the \mtex-3.4.1\... directory, simply copy these to the
	appropriate relative path within \mtex-3.4.1\... For example copy the
	file called om_patala.m from:

		\MTEX_ReplacementFiles\tools\orientationMappings\

	to:

		\mtex-3.4.1\tools\orientationMappings\


USAGE

	To plot a grain boundary map with the boundaries colored according to
	their misorientations, using the Patala colorcode, use MTEX's
	plotBoundary function with the following arguments:

	plotBoundary(grains,'property','misorientation','colorcoding','patala')

	The first argument is a GrainSet object created using MTEX, the second
	argument specifies that you want to colorize the boundaries according
	to a specific property, the third argument indicates that the property
	of interest is the misorientation, the fourth argument indicates that
	you want to specify the colorcoding that is to be used, the fifth
	argument indicates that you want to use the patala colorcode.

	The colorbar legend consists of two-dimensional projections of spherical
	cuts through the misorientation space. Each cut provides the standard
	stereographic triangle for a fixed misorientation angle (i.e. they are
	iso-misorientation angle sections). The colorbar command idendifies
	the crystal symmetry from the plot that is created using plotBoundary,
	which is why you must create the boundary map first.

	After plotting a grain boundary map using the above syntax you can plot
	a color legend using MTEX's colorbar function with the following 
	arguments:

	colorbar('omega',[5,15,25])

	The first argument indicates that you want to specify which misorientation
	angle sections are plotted. The second argument is a vector whose values
	are the misorientation angles (in degrees) for which you want sections 
	plotted. In the	above example, three sections will be plotted, one for
	5 degrees, another for 15 degrees, and a third for 25 degrees. The user
	may specify as many sections as they want and in any order. If colorbar
	is called without any arguments a default of 6 sections are plotted, which
	are linearly spaced between 10 degrees and the maximum misorientation angle
	for a given point group symmetry.