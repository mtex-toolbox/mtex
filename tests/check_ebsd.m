%% MTEX check simulateEBSD and calcODF
% check for the dependency between the number of sample
% orientations and the error between the estimated and the 
% true ODF

for i = 1:5

  ebsd = simulateEBSD(santafee,10^i);

  odf = calcODF(ebsd);

  e(i) = calcerror(odf,santafee,'resolution',2.5*degree);
  
end

plot(e)
