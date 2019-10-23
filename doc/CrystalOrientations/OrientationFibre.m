%% Fibres of Orientations
%
%% 
% A fibre in orientation space is essentially a line connecting two
% orientations and can be represented in MTEX by a single variable of type
% <fibre.fibre.html fibre>. To illustrate the definition of a fibre we
% first define *cube* and *goss* orientation

% define crystal and specimen symmetry
cs = crystalSymmetry('432');
ss = specimenSymmetry('1');

% and two orientations
ori1 = orientation.cube(cs,ss);
ori2 = orientation.goss(cs,ss);

%%
% and then the fibre connecting both orientations

f = fibre(ori1,ori2)

%%
% Finally we plot everything into the Euler space

% plot the fibre
plot(f,'DisplayName','Fibre','linewidth',4,'linecolor','green')

% and on top of it the orientations
hold on
plot(ori1,'DisplayName','CUBE','MarkerSize',12,'MarkerFaceColor','darkred','MarkerEdgeColor','k')
plot(ori2,'DisplayName','GOSS','MarkerSize',12,'MarkerFaceColor','blue','MarkerEdgeColor','k')
hold off
legend

%%
% Alternatively, we may visualize the fibre also in axis angle space

% plot the fibre
plot(f,'linecolor','green','linewidth',6,'axisAngle')

% and on top of it the orientations
hold on
plot(ori1,'MarkerFaceColor','darkred','MarkerSize',15,'axisAngle')
plot(ori2,'MarkerFaceColor','blue','MarkerSize',15)
hold off

%%
% Obviously, *f* is not a full fibre. Since, the orientation space has no
% boundary a full fibre is best thought of as a circle that passes trough
% two fixed orientations. In order to define the full fibre us the option
% *full*

f = fibre(ori1,ori2,'full')

hold on
plot(f,'linecolor','gold','linewidth',3,'project2FundamentalRegion')
hold off

%% Defining a fibre by directions
%
% Alternatively, a fibre can also be defined by a pair of a crystal and a
% specimen direction. In this case it consists of all orientations that
% alignes the crystal direction parallel to the specimen direction. As an
% example we define the fibre of all orientations such that the c-axis
% (001) is parallel to the z-axis by

f = fibre(Miller(0,0,1,cs),vector3d.Z)

plot(f,'linecolor','gold','linewidth',4,'project2FundamentalRegion','axisAngle')


%%
% If both directions of type Miller the fibre corresponds to all
% misorientations which have these two direcetion parallel.
%
% Finally, a fibre can be defined by an initial orientation *ori1* and a
% direction *h*, i.e., all orientations of this fibre satisfy
%
%   ori = ori1 * rot(h,omega)
%
% and
%
%   ori * h = ori1 * h
%
% The following code defines a fibre that passes through the cube
% orientation and rotates about the (111) axis.

f = fibre(ori1,Miller(1,1,1,cs))

plot(f,'linecolor','darkred','linewidth',4,'project2FundamentalRegion','axisAngle')

%% predefined fibres
% MTEX includes also a list of predefined fibres, e.g., alpha-, beta-,
% gamma-, epsilon-, eta- and tau fibres. Those can be defined by

beta = fibre.beta(cs,'full');

%%
% Note, that it is now straight forward to define a corresponding fibre ODF
% by

odf = fibreODF(beta,'halfwidth',10*degree)

% and plot it in 3d
plot3d(odf)

% this adds the fibre to the plots
hold on
plot(beta.symmetrise,'lineColor','b','linewidth',4)
hold off

%% Visualize an ODF along a fibre
%

plot(odf,fibre.gamma(cs))


%% Compute volume of fibre portions

100 * volume(odf,beta,10*degree)

