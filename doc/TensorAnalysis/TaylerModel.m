%% Tayler Model
% 
%
%%
%
%
%% Open in Editor
%
%% Contents

% consider cubic crystal symmetry
cs = crystalSymmetry('432');

% define a family of slip systems
sS = slipSystem.fcc(cs);

% some strain
q = 0;
epsilon = tensor.diag([1 -q -(1-q)],'name','strain')

% define a crystal orientation
ori = orientation('Euler',0,30*degree,15*degree,cs)

% compute the Taylor factor
[M,b,mori] = calcTaylor(inv(ori)*epsilon,sS.symmetrise);

%% The orientation dependence of the Taylor factor
% The following code reproduces Fig. 5 of the paper of Bunge, H. J. (1970).
% Some applications of the Taylor theory of polycrystal plasticity.
% Kristall Und Technik, 5(1), 145-175.
% http://doi.org/10.1002/crat.19700050112

% set up an phi1 section plot
sP = phi1Sections(cs,specimenSymmetry('222'));
sP.phi1 = (0:10:90)*degree;

% generate an orientations grid
oriGrid = sP.makeGrid('resolution',2.5*degree);
oriGrid.SS = specimenSymmetry;

% compute Taylor factor for all orientations
tic
[M,~,mori] = calcTaylor(inv(oriGrid)*epsilon,sS.symmetrise);
toc

% plot the taylor factor
sP.plot(M,'smooth')

mtexColorbar


%% The orientation dependency of the rotation value 
% Compare Fig. 8 of the above paper

sP.plot(mori.angle./degree,'smooth')
mtexColorbar


%% Texture evolution during rolling

% define some random orientations
ori = orientation.rand(1000,cs);

% 30 percent strain
q = 0;
epsilon = 0.3 * tensor.diag([1 -q -(1-q)],'name','strain');

% 
numIter = 10;
progress(0,numIter);
for sas=1:numIter

  % compute the Taylor factors and the orientation gradients
  [M,~,mori] = calcTaylor(inv(ori) * epsilon ./ numIter, sS.symmetrise);
  
  % rotate the individual orientations
  ori = ori .* mori;
  progress(sas,numIter);
end

% plot the resulting pole figures
plotPDF(ori,Miller({0,0,1},{1,1,1},cs),'contourf')
mtexColorbar

