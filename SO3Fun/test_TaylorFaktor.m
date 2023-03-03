clear

%% compute directly on grid

cs = crystalSymmetry('432');
sS = slipSystem.bcc(cs)

% some plane strain
q = 0;
epsilon = strainTensor(diag([1 -q -(1-q)]))

% set up an phi1 section plot
sP = phi1Sections(cs,specimenSymmetry('222'));
sP.phi1 = (0:10:90)*degree;
 
% generate an orientations grid
oriGrid = sP.makeGrid('resolution',5*degree);
oriGrid.SS = specimenSymmetry;

% compute Taylor factor for all orientations
[M,~,W] = calcTaylor(inv(oriGrid)*epsilon,sS.symmetrise);

% %% plot the taylor factor
% 
% figure(1)
% sP.plot(M,'smooth')
% mtexColorbar

%% plot the spinTensor

figure(2)
comp = vector3d(W).xyz;
sP.plot(comp(:,1),'smooth','complete')
%sP.plot(W.angle./degree,'smooth')
mtexColorbar

%% compute SO3Fun's

% compute Taylor factor for all orientations
[M2,~,W2] = calcTaylor(epsilon,sS.symmetrise,'bandwidth',32);

% %% plot the taylor factor
% 
% figure(3)
% m = M2.eval(oriGrid);
% sP.plot(m,'smooth')
% 
% mtexColorbar
% %plot(M2,'phi1',(0:10:90)*degree)

%% plot the spinTensor

figure(4)
% v = W2.eval(oriGrid);
% w = spinTensor(v(:).',W2.CS).';
% sP.plot(w.angle./degree,'smooth')

W2.CS=crystalSymmetry;
plotSection(W2.SO3F(1),'phi1',(0:10:90)*degree)
mtexColorbar






















%% Test spin tensor
clear
cs = crystalSymmetry('432');
sS = slipSystem.bcc(cs)

% some plane strain
q = 0;
epsilon = strainTensor(diag([1 -q -(1-q)]))






%%

load('Taylor.mat')

N = 33;
SRight = cs;
SLeft = specimenSymmetry;
nodes = quadratureSO3Grid(2*N,'ClenshawCurtis',SRight,SLeft);
ori = nodes(1234);


W2

tic
[M,~,W] = calcTaylor(inv(ori)*epsilon,sS.symmetrise)
toc
vector3d(W)

W2.eval(ori)















% 
% 
% 
% 
% %% Texture Evolution
% 
% cs = crystalSymmetry('432');
% 
% mtexdata csl
% 
% % compute grains
% grains = calcGrains(ebsd('indexed'));
% grains = smooth(grains,5);
% 
% % remove small grains
% grains(grains.grainSize <= 2) = []
% 
% 
% sS = symmetrise(slipSystem.fcc(grains.CS));
% 
% 
% 
% % define some random orientations
% ori = orientation.rand(10000,cs);
% 
% % 30 percent plane strain
% q = 0;
% epsilon = 0.3 * strainTensor(diag([1 -q -(1-q)]));
% 
% % %%
% % numIter = 10;
% % progress(0,numIter);
% % for sas=1:numIter
% % 
% %   % compute the Taylor factors and the orientation gradients
% %   [M,~,W] = calcTaylor(inv(ori) * epsilon ./ numIter, sS.symmetrise,'silent');
% % 
% %   % rotate the individual orientations
% %   ori = ori .* orientation(-W);
% %   progress(sas,numIter);
% % end
% % 
% % 
% % 
% % 
% % %%
% 
% numIter = 10;
% progress(0,numIter);
% 
% [Taylor,~,spin] = calcTaylor(epsilon ./ numIter, sS.symmetrise,'bandwidth',32);
% 
% for sas=1:numIter
%   
%   M = Taylor.eval(ori);
%   W = spinTensor(spin.eval(ori).').';
%   % rotate the individual orientations
%   ori = ori .* orientation(-W);
%   progress(sas,numIter);
% end
% 
% 
% 
% 
% 
% 
% 
% %%
% 
% % plot the resulting pole figures
% 
% % set new annotation style to display RD and ND
% pfAnnotations = @(varargin) text([vector3d.X,vector3d.Y,vector3d.Z],{'RD','TD','ND'},...
%   'BackgroundColor','w','tag','axesLabels',varargin{:});
% setMTEXpref('pfAnnotations',pfAnnotations);
% 
% plotPDF(ori,Miller({0,0,1},{1,1,1},cs),'contourf')
% mtexColorbar
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
