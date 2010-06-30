%% Geesthacht interface
% An examples how to import Geesthacht data.
%

%% specify crystal and specimen symmetries

cs = symmetry('cubic');
ss = symmetry;

%% specify the file names

fname = [mtexDataPath '/geesthacht/ST42-104-110.dat'];


%% specify crystal directions

h = {Miller(1,0,4,cs),Miller(1,0,4,cs),Miller(1,1,0,cs),Miller(1,1,0),cs};

%% import the data

pf = loadPoleFigure(fname,h,cs,ss);

%% plot data

close; figure('position',[100,100,800,300]);
plot(pf)

%% See also
% [[interfacesPoleFigure_index.html,interfaces]] [[loadPoleFigure.html,loadPoleFigure]]
% [[S2Grid_plot.html,plot]] [[symmetry_symmetry.html,symmetry]] 
% [[Miller_Miller.html,Miller]]

%% Specification
%
% * *.dat ascii - files
% * many pole figures per file
%
%
%% Precise specification
%
% Geesthacht-Format:
%
% ==================
% Die erste Zeile und alle Zeilen mit "$" in der ersten Spalte sind Kommentarzeilen.
%  1. Zeile: Creator          : Datum ... 
%  3. Zeile: Messprogramm     : ...
%  5. Zeile: Messdatendatei   : ...
% u.s.f.
% Die zeilen nach dem letzten $-zeichen enthalten folgende daten:
% Spalte 1: lfd. Nummer
%        2: 2-theta des reflexes
%        3: theta des reflexes
%        4: 90.-Polwinkel
%        5: azimut
%        6:% Geesthacht-Format:
% ==================
% Die erste Zeile und alle Zeilen mit "$" in der ersten Spalte sind Kommentarzeilen.
%  1. Zeile: Creator          : Datum ... 
%  3. Zeile: Messprogramm     : ...
%  5. Zeile: Messdatendatei   : ...
% u.s.f.
% Die zeilen nach dem letzten $-zeichen enthalten folgende daten:
% Spalte 1: lfd. Nummer
%        2: 2-theta des reflexes
%        3: theta des reflexes
%        4: 90.-Polwinkel
%        5: azimut
%        6: intesit�t
% alle weiteren werte werden nicht ben�tigt.
% 
% die messdaten sind ringf�rmig angeordnet:
%     polwinkel - anzahl der daten - azimuth-schrittweite
%  1:   0.00   		 3 		120
%  2:   5.40   		 6  		60
%  3:  11.80 			12  		30
%  4:  16.25  		18  		20     
%  5:  21.75  		24  		15      
%  6:  27.25   		30  		12
%  7:  33.85  		36  		10     
%  8:  38.45  		42   		8.1    
%  9:  44.30   		48   		7.5
% 10:  50.20  		54        
% 11:  56.25  		60   		6.0   
% 12:  62.50   		66
% 13:  68.90  		72   		5.0  
% 14:  75.60  		78         
% 15:  82.60   		84
% 16:  90.00  		46   		4.0   
% F�r den Polwinkel 90� wird nur der halbe Umfang mit 46 punkten gemessen, die fehlenden daten ergeben sich aus der symmetrischen erg�nzung.
%      Messwertanzahl  = 679 
% + 16 UNTERGRUNDWERTE = 695
% + 44 symm. Erg�nzung = 723
% 
% 
% In einer Geesthacht-Datei k�nnen Messungen mehrerer Reflexe hintereindander folgen (siehe: Messdatendatei). Hier sind es zwei: 104 und 110 von H�matit. 
% --------------------------------------------------------------------------------
% 
% 
% 
% 
%   intesit�t
% alle weiteren werte werden nicht ben�tigt.
% 
% die messdaten sind ringf�rmig angeordnet:
%     polwinkel - anzahl der daten - azimuth-schrittweite
%  1:   0.00   		 3 		120
%  2:   5.40   		 6  		60
%  3:  11.80 			12  		30
%  4:  16.25  		18  		20     
%  5:  21.75  		24  		15      
%  6:  27.25   		30  		12
%  7:  33.85  		36  		10     
%  8:  38.45  		42   		8.1    
%  9:  44.30   		48   		7.5
% 10:  50.20  		54        
% 11:  56.25  		60   		6.0   
% 12:  62.50   		66
% 13:  68.90  		72   		5.0  
% 14:  75.60  		78         
% 15:  82.60   		84
% 16:  90.00  		46   		4.0   
% F�r den Polwinkel 90� wird nur der halbe Umfang mit 46 punkten gemessen, die fehlenden daten ergeben sich aus der symmetrischen erg�nzung.
%      Messwertanzahl  = 679 
% + 16 UNTERGRUNDWERTE = 695
% + 44 symm. Erg�nzung = 723
% 
% 
% In einer Geesthacht-Datei k�nnen Messungen mehrerer Reflexe hintereindander folgen (siehe: Messdatendatei). Hier sind es zwei: 104 und 110 von H�matit. 
% --------------------------------------------------------------------------------
