%% Grids of Orientation
% 
% In many usecases one is interested in grid of orientations that somehow
% uniformely cover the orientation space. As there are many different grid
% there is a seperate topic <SO3GridDemo.html orientation grids>. The
% simplest way of generating equispaced orientations with given resolution
% is by the command

ori = equispacedSO3Grid(cs,'resolution',2.5*degree)
