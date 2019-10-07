%% Spherical Grids
%
%%
%

S2G = regularS2Grid('resolution',5*degree,'upper')

plot(S2G,'upper')

%%
% 

S2G = equispacedS2Grid('resolution',5*degree,'upper')

plot(S2G,'upper')