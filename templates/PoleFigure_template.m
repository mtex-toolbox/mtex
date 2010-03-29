%% Standard template
%% Visualize Data
% plot of the raw data
plot(pf)

%% ODF estimatio

% estimate some ODF
odf = calcODF(pf)

%% Plot Caclulated Pole Figures

plotpdf(odf,h)
