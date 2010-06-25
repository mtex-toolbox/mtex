%% The Aachen Data Interface
%
% The following examples shows how to import a Aachen data set.

%% specify crystal and specimen symmetries

cs = symmetry('cubic');
ss = symmetry;

%% specify the file names

fname = [mtexDataPath '/aachen/st08-1'];

%% import the data

pf = loadPoleFigure(fname,cs,ss);

%% plot data

plot(pf) 

%% See also
% [[interfacesPoleFigure_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]
%
%% Specification
% * txt - files
% * many pole figures per file
% * three headerlines per pole figure
% * specimen grid specified in the second headerline
%
%% open questions: 
% * Multiplikationsfaktor ?
% * superposed pole figures?
%
%
%% precise specification:
%Aachen-Format:
%==============
%1. Zeile: text2  78 characters
%2. Zeile: hkl    (miller indices, 5 characters)
%          xxxx   ( kristall system, 5 characters, meist unbenutzt)
%          dteta  (polwinkel-schrittweite des messrasters 
%          dphi   (azimuth-schrittweite des messrasters)
%          tetlim (maximaler polwinkel )
%          iwin   (0=position der daten in den mitten der rasterfelder,
%                  1=position auf den ecken)
%          isym   (0=vollst�ndige polfigur, 2= halbe polfigur,
%                  4=viertel polfigur)
%          fmt    (leseformat der daten)
%3. Zeile: mult   (faktor mit dem die daten multipliziert wurden)
%          ----   20 unbenutzte characters, text1: weitere 50 character
%
%In der Aachen-datei k�nnen mehrere Messungen hintereinander stehen, hier 2.
%--------------------------------------------------------------------------------
