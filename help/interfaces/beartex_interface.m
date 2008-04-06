%% The BearTex Data Interface
% 
% The following examples shows how to import a BearTex data set.

%% specify crystal and specimen symmetries

cs = symmetry('cubic');
ss = symmetry;

%% specify the file names

fname = [mtexDataPath '/BearTex/Test_2.XPa'];

%% import the data

pf = loadPoleFigure(fname,cs,ss);

%% plot data

close; figure('position',[100,100,800,500]);
plot(pf)

%% See also
% [[interfaces_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]

%% Specification
%
% * *.XPa  ascii - files
% * many pole figures per file
% * 7 headerlines per pole figure
%
%% precise specification:
%
% Different data formats are used in texture analysis. The POPLA package
% has made an admirable attempt to standardize them with the so-called
% "old Berkeley" format. Most of the BEARTEX programs will accept this
% format if data are imported from other systems. However the standard for
% BEARTEX is a slightly modified version which became necessary because of
% application to low crystal symmetry materials (with larger than 1-digit
% and negative hkl's) and a more general choice of pole figure ranges.
% Unfortunately, for lack of space in the monitor screen, in the display
% only 3 digits for hkl are displayed in POXX and CONT; be careful !!
% (e.g. 1 2 12 appears as 1 2 2). This "new Berkeley" format has two
% additional lines preceeding each data set and the old two lines are
% slightly modified.
% 
% This ASCII file is used to enter experimental pole figures and for
% graphic representation of pole figures and ODs (e.g. with programs POXX
% and CONT).  The structure is a set of integer density values with
% increasing pole distance () and azimuth (
% ). The density values may be normalized or not normalized, depending on
% the application. The optimal use of the 4 digits (largest number is
% 9999) can be achieved with a zoom factor. For typical normalized texture
% data the m.r.d (multiples of a random distribution) value is multiplied
% by 100. The minimum increment is 5�. Most programs (such as WIMV)
% require 5� increments for input of experimental pole figures, either
% measured or interpolated.
% 
% Below is the first pole figure on the file DEMO1.XPa contained in your
% installation. It is an "experimental pole figure" in 5� increments on
% () and (), extending in pole distance from 0 to 90� and azimuth from 0
% to 355�.
% 
% line 1: title, code # (in column 80) to indicate new Berkeley format
% (a79,a1)
% 
% line 2: free for user (Used in BEARTEX only in CORR, in the example H is
% a code for the goniometer, 6 and 12 are values for background)
% 
% line 3: free for user.
% 
% line 4-5: Reserved for future control parameters (Not used at the moment).
% 
% line 6: lattice parameters (or fractions), crystal and sample symmetry
% codes (6f10.2,2i5)
% 
% line 7: control parameters: h,k,l,  min,  max,  increment (pole
% distance),  min,  max,  increment (azimuth), iw, jw (1 if measured at
% corners of cell, 0 if in center, 1 is standard), 1, 2, 3 are sample
% orientation codes used in POPLA, not used in BEARTEX. (1x,3i3,6f5.1,2i2,3i2)
%         For non-programmers: 1 space, 3 fields of 3-digit integers, 6 fields of
% 5-digit integers, 2 fields of 2-digit integers, 3 fields of 2-digit integers
% line 8 etc.: density data in integers. For triclinic pole figure 19
% rings at 72  values arranged in 4 lines per ring (4(1x,18i4,/). For
% orthorhombic pole figures 19 rings at 19 values arranged in a single
% line (1x,19i4) 1 space, 19 fields of 4-digit integers
% 
% last line: blank. It is used to recognize the end of the data set and
% therefore required. Some editors delete blank lines at the end of the
% document and you must add it again! Another data set of identical
% structure may follow the first one.
