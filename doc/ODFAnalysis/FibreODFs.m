%% Fibre ODFs
%
% TODO: extend this
%%
% A fibre is represented in MTEX by a variable of type <fibre.fibre.html
% fibre>.

cs = crystalSymmetry.load('Ti-Titanium-alpha.cif')

% define the fibre to be the beta fibre
f = fibre.beta(cs)

% define a fibre ODF
odf = fibreODF(f,'halfwidth',10*degree)

% plot the odf in 3d
plot3d(odf)
