%% Juelich Interface
% An examples how to import Juelich data.
%
%% specify crystal and specimen symmetries

cs = symmetry('cubic');
ss = symmetry;

%% specify the file names

fname = [mtexDataPath '/juelich/104.hem'];

%% import the data

pf = loadPoleFigure(fname,cs,ss);

%% plot data

plot(pf)

%% See also
% [[interfacesPoleFigure_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]]


%% Specification
%
% * *.hem ascii - files
% * one pole figures per file
%
%
%% Precise specification:
%
% Juelich-Format:
% ===============
% 1. Zeile: text
% 2. Zeile: text: alpha=polwinkel, beta=azimuth, intensit�t
% Die folgenden datenzeilen sind wie folgt ringweise angeordnet:
%      Polwinkel - anzahl der messpunkte - azimuthabstand
%  1:  90.00		  	50  			 7.2   
%  2:  82.92  		50   			 7.2   
%  3:  75.84  		50  			 7.2
%  4:  68.27  		48  			 7.5
%  5:  61.71  		45  			 8.0   
%  6:  54.68  		45  			 8.0
%  7:  47.67  		40   			 9.0   
%  8:  40.72  		36  			10.0   
%  9:  33.85  		30  			12.0
% 10:  27.12  		24  			15.0  
% 11:  20.69  		12  			30.0  
% 12:  14.93  		10  			36.0
% 13:  10.98   		 8  			45.0
% = 448 messpunkte, 
% dann folgen noch weitere messpunkte zur abdeckung des "blinden flecks" meist in form eines kreuzes.
% 
% In einer Juelich-Datei ist immer nur die Messung eines Reflexes enthalten.
% --------------------------------------------------------------------------------
