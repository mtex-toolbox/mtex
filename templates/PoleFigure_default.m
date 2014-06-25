%% Default template

%% Visualize the raw 

% plot of the raw data
plot(pf)

%% ODF estimation

% estimate an ODF
odf = calcODF(pf)

%% Plot Caclulated Pole Figures

plotPDF(odf,h)
