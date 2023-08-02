function display(SO3G)
% standard output

refSystems = [char(SO3G.CS,'compact') ' ' getMTEXpref('arrowChar') ' ' char(SO3G.SS,'compact')];

displayClass(SO3G,inputname(1),'moreInfo',refSystems);

disp(['  scheme: ',SO3G.scheme])
disp(['  bandwidth: ',num2str(SO3G.bandwidth)])
disp(['  grid: ',char(SO3G)]);
disp(['  size: ',size2str(SO3G.nodes)]);

