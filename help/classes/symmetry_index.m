%% The Class symmetry
% a class to represent crystal or specimen symmetries
%
%% Description
%
% The class *symmetry* may represent a crystal or a specimen symmetry. It
% has to be passed as a parameter when defining [[ODF_index.html,ODFs]], 
% [[PoleFigure_index.html,PoleFigures]], or a 
% [[Miller_index.html,Miller indice]]. So far the MTEX toolbox only
% provides the Laue groups since they are the only relevant in diffration
% analysis.
%
%% Defining a symmetry
%
% MTEX supportes the *Schoenflies* notation on Laue groups as well as the
% *international* notation. In the case of non cubic crystal symmetry the
% length of the crystal axis has to be specified as a second argument to
% the constructor [[symmetry_symmetry.html,symmtry]] and in the case of
% triclinic crystal symmetry the angles between the axes has to be passed
% as third argument. Hence, valid definitions are:

cs = symmetry('triclinic',[1,2.2,3.1],[80*degree,85*degree,95*degree]);
cs = symmetry('-3m',[2.5,2.5,1]);
ss = symmetry('O');

%% Calculations
%
% applaying the specimen symmetry from the left and the crystal symmetry from the 
% right onto a [[quaternion_index.html,orientation]] results in a vector
% containing all crystallographically equivalent orientations.

ss * euler2quat(0,0,pi/4) * cs;  % all crystallographically equivalent orientations

%% Ploting symmetries
%
% Symmetries are visualized by plotting their main axes and the
% corresponding equivalent directions

close; figure('position',[50,50,400,400])
plot(cs,'reduced')
