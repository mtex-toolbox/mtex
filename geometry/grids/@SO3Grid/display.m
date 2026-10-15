function display(S3G)
% standard output

refSystems = [char(S3G.CS,'compact') ' ' getMTEXpref('arrowChar') ' ' char(S3G.SS,'compact')];

displayClass(S3G,inputname(1),'moreInfo',refSystems);

disp(['  grid: ',char(S3G)]);
