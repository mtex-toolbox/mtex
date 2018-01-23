%% *|S2AxisHFieldHarmonic|*
%% Defining a |S2AxisFieldHarmonic|
%
%%
% *Definition via function handle*
%
% If you have a function handle for the function you could create a |S2AxisFieldHarmonic| via quadrature.
% At first lets define a function handle which takes <vector3d_index.html |vector3d|> as an argument and returns antipodal <vector3d_index.html |vector3d|>:

f = @(v) vector3d(v.x, v.y, 0*v.x, 'antipodal');
%% 
% Now you can call the quadrature command to get |sAF2| of type |S2AxisFieldHarmonic|
sAF = S2AxisFieldHarmonic.quadrature(@(v) f(v))

%% Visualization
%
% the default |plot|-command

plot(sAF);
%%
% * same as quiver(sAF1)

%%
% 3D plot which you can rotate around
clf;
quiver3(sAF);
