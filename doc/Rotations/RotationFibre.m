%% Fibers
%
%% 
%
% The set of all rotations that rotate a certain vector |u| onto a certain
% vector |v| defines a fibre in the rotation space.

u = xvector;
v = yvector;

% define the fibre
f = fibre(u,v)

plot(f,'axisAngle','lineWidth',3,'lineColor','red')
axis off

%%
% A discretization of such a fibre can be found using the command
% <fibre.rotation.html |rotation|>

rot = rotation(f)

% plot the rotations along the fibre
hold on
plot(rot)
hold off

