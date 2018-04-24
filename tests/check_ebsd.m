%% MTEX check calcEBSD and calcODF
% check for the dependency between the number of sample
% orientations and the error between the estimated and the 
% true ODF

for i = 1:5

  ebsd = discreteSample(SantaFe,10^i);

  odf = calcODF(ebsd);

  e(i) = calcError(odf,SantaFe,'resolution',2.5*degree);
  
end

plot(e)
