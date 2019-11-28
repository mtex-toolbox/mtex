%Probleme bei S2FunHarmonic

G=S2FunHarmonic(eye(40))

G=reshape(G,2,5,2,2)
%Fehler in der Anzeige, hier koennte man die Funktion ndims aus 
%SO3FunHarmonic einfuegen. So erhaelt man size: 2x5x2x2

%%

%haufig nicht matrixwertig. z.B.:
%G.bandwith erzeugt Vektor von Funktionen aus Matrix von Funktionen:
G.bandwidth=2

%rotation.rand(x,3) erzeugt immer Vektor der Laenge x und keine Matrix 
%mit 3 Spalten. Ist das gewollt?
rotation.rand(3,3) % erzeugt 3x1

disp('Konsistenz?')
F1=FourierODF([1;2;3;4;5;6;7;8;9;10],crystalSymmetry);
F2=S2FunHarmonic([1;2;3;4;5;6;7;8;9;10]);
F3=SO3FunHarmonic([1;2;3;4;5;6;7;8;9;10],crystalSymmetry);
v1=rotation.rand(4,4);
for i=1:4 v2(i,:)=vector3d(rand(3,4)); end

disp('Ergebnis von F (length=1) nach Anwendung von eval mit Matrix von Punkten:')
disp([' size von ODF: ' size2str(eval(F1,v1))])
disp([' size von S2FunHarmonic: ' size2str(eval(F2,v2))])
disp([' size von SO3FunHarmonic: ' size2str(eval(F3,v1))])