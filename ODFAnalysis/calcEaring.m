function h = calcEaring(indata,sS,prop,varargin)
% compute earing from odf and slip systems
%
% Description:
% This function calculates the height |h| at each peripheral position of
% a cup drawn from a polycrystalline bcc metal sheet.
% In the analytical treatment, the polycrystalline sheet is assumed to be
% an aggregate of single crystals (grains) with various orientations.
% In the original paper, an orientation distribution function (ODF)
% constructed from texture data was used to calculate the weight of each 
% single crystal.
% In this function, ebsd or grain data can be used:
%
% * For ebsd data, an ODF is first calculated. 
%   Following that, there are 2 options:
%   (1) Calculate ODF components & volume fractions using MTEX-default
%   functions, or
%   (2) Calculate the volume fractions of a discretised ODF.
%   For both options, the volume fraction is used as the weight.
% * Alternatively, for grain data, weights are computed using the grain
%   area fraction.
% The ear may be calculated crystallographically by considering both,
% restricted glide and pencil glide; with the former returning better
% predictions in the original paper.
%
% Syntax
%  calcEaring(grains,sS,prop)
%
% Input
%  ori  - @orientation
%  sS   - @slipSystem
%  prop - @struct
%
% Output
%  h    - @double, height at each peripheral position of a cup drawn from a polycrystalline bcc metal sheet.
%
% Options
%  discrete - use a discretised ODF
%
% Author
%
%  * Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
% References
% 
% * N. Kantake, Y. Tozawa, S. Yamamoto, Calculations of earing in deep
% drawing for bcc metal sheets using texture data, Int. J Mech. Sci.,
% vol. 27(4), pp. 249-256, 1985.
% https://www.sciencedirect.com/science/article/pii/0020740385900839
%

isFlag = check_option(varargin,'discrete');

if isa(indata,'EBSD')
  % If using ebsd data, compute the weights using the ODF components or intensity
  disp('---')
  disp('Calculating the ODF from ebsd data...');
  % compute an optimal kernel
  psi = calcKernel(indata(indata.CS).orientations);
  % compute the ODF with the kernel psi
  odf = calcDensity(indata(indata.CS).orientations,'kernel',psi);
  disp('Done!');
  
  if isFlag == false
    % calculate the components and their volume fractions to use as the
    % weights (wt)
    disp('---')
    disp('Calculating MTEX-default ODF components and volume fractions...');
    [ori, vol] = calcComponents(odf,'maxIter',1000,'exact');
    % normalize the volume fraction
    wt = vol./sum(vol);
    
  elseif isFlag == true
    disp('---')
    disp('Calculating discrete ODF intensity from ebsd data...');
    % make a regular grid using 5*degree step size
    % MTEX BUG: not returning the correct ori size
    %         ori = regularSO3Grid(odf.CS,odf.SS,'resolution',5*degree,'Bunge');
    
    x = linspace(0,90*degree,19);
    y = linspace(0,360*degree,73);
    z = linspace(0,90*degree,19);
    % create a meshgrid
    [phi1,Phi,phi2] = meshgrid(x, y, z);
    ori = orientation.byEuler(phi1,Phi,phi2,odf.CS,odf.SS);
    
    % return the ODF intensity at the gridded points
    odf.opt.intensity = odf.eval(ori);
    % make negative f(g) values == 0
    odf.opt.intensity(odf.opt.intensity<0) = 0;
    
    disp('Done!');
    disp('---')
    disp('Calculating discrete ODF volume fractions...');
    % calculate the ODF volume fraction (v) to use as the weight (wt)
    wt = calcODFvolFraction(odf);
    % make single column arrays
    ori = ori(:);
    wt = wt(:);
  end
  disp('Done!');
  disp('---')
  
elseif isa(indata,'grain2d')
  % If using grain data, compute the weights using the grain area
  ori = indata.meanOrientation;
  wt = indata.area./sum(indata.area);
  
else
  error('Only @ebsd or @grain2d data accepted.')
end
%%




warning(sprintf(['\ncalcEaring assumes the orientation data of the sheet is in following format:',...
  '\nRD = horizontal; TD = vertical; ND || deep drawing axis = out-of-plane']));

% Check for symmetrised slip system(s)
isSymmetrised = sum(eq(sS(1),sS)) > 1;
if ~isSymmetrised
  warning(sprintf('\nSymmetrised slip system(s) required.'));
  sS = sS.symmetrise;
end


% Pre-calculate repeated values
% Note: In MTEX, Bunge's notation is the default texture convention.
% However, in the paper, the Roe's texture convention was applied.
% Therefore, the orientation data needs to comnverted from Bunge to Roe.
[psi, theta, phi] = Euler(ori,'Roe');

l3 = -sin(theta) .* cos(phi);
m3 =  sin(theta) .* sin(phi);
n3 =  cos(theta);

l4 =  (cos(psi) .* cos(theta) .* cos(phi)) - (sin(psi) .* sin(phi));
m4 = -(cos(psi) .* cos(theta) .* sin(phi)) - (sin(psi) .* cos(phi));
n4 =   cos(psi) .* sin(theta);

l5 = (n3 .* m4) - (m3 .* n4);
m5 = (l3 .* n4) - (n3 .* l4);
n5 = (m3 .* l4) - (l3 .* m4);


%% Rotate the orientations incrementally about the pre-defined RD
% Here RD || map horizontal
alpha = linspace(0,360*degree,73); % Angle to RD

% Pre-allocate variables
temp = zeros(length(ori),length(sS));
epsilonS = zeros(length(ori),1);
epsilonP_wtSum = zeros(1,length(alpha));
h = zeros(1,length(alpha));

disp('---')
disp('Calculating the earing...')
progress(0,length(alpha));
for ii = 1:length(alpha)
  
  l1 = (l5 .* cos(alpha(ii))) - (l4 .* cos(alpha(ii)));
  m1 = (m5 .* cos(alpha(ii))) - (m4 .* sin(alpha(ii)));
  n1 = (n5 .* cos(alpha(ii))) - (n4 .* sin(alpha(ii)));
  
  l2 = (l4 .* cos(alpha(ii))) + (l5 .* sin(alpha(ii)));
  m2 = (m4 .* cos(alpha(ii))) + (m5 .* sin(alpha(ii)));
  n2 = (n4 .* cos(alpha(ii))) + (n5 .* sin(alpha(ii)));
  
  for kk = 1:length(sS)
    aN = ((sS(kk).n.hkl(1) .* l1) + (sS(kk).n.hkl(2) .* m1) + (sS(kk).n.hkl(3) .* n1)) /...
      sqrt(sum(sS(kk).n.hkl.^2));
    bN = ((sS(kk).n.hkl(1) .* l2) + (sS(kk).n.hkl(2) .* m2) + (sS(kk).n.hkl(3) .* n2)) /...
      sqrt(sum(sS(kk).n.hkl.^2));
    %         cN = ((sS(kk).n.hkl(1) .* l3) + (sS(kk).n.hkl(2) .* m3) + (sS(kk).n.hkl(3) .* n3)) /...
    %             sqrt(sum(sS(kk).n.hkl.^2));
    
    dN = ((sS(kk).b.uvw(1) .* l1) + (sS(kk).b.uvw(2) .* m1) + (sS(kk).b.uvw(3) .* n1)) /...
      sqrt(sum(sS(kk).b.uvw.^2));
    eN = ((sS(kk).b.uvw(1) .* l2) + (sS(kk).b.uvw(2) .* m2) + (sS(kk).b.uvw(3) .* n2)) /...
      sqrt(sum(sS(kk).b.uvw.^2));
    %         fN = ((sS(kk).b.uvw(1) .* l3) + (sS(kk).b.uvw(2) .* m3) + (sS(kk).b.uvw(3) .* n3)) /...
    %             sqrt(sum(sS(kk).b.uvw.^2));
    
    temp(:,kk) = (((aN .* dN) - (bN .* eN) - prop.miu0) .^ (1/prop.n)) .* abs(bN);
    
  end
  
  % Radial strain at a given alpha(ii)
  epsilonS = sum(temp,2); % rowwise sum over all slip systems since
  % rows = orientations; columns = slip systems
  epsilonP = epsilonS .* wt;
  epsilonP_wtSum(ii) = sum(epsilonP);
  
  progress(ii,length(alpha));
end

%% Calculate all deep drawing values
% sigma = (prop.YS / 9.81); % convert from N/mm2 to kg/mm2
% K = (sigma / prop.k)^(1 / prop.n);

Rsquare = (2 * ((prop.radiusPunchProfile + (prop.thicknessBlank / 2)) ^ 2)) +...
    ((prop.radiusPunchProfile + (prop.thicknessBlank / 2)) * (prop.radiusPunch - prop.radiusPunchProfile) * pi()) +...
    ((prop.radiusPunch - prop.radiusPunchProfile) ^ 2);

hW = ((prop.radiusBlank ^ 2) - Rsquare) / (prop.radiusPunch + prop.radiusDie);

epsilonP_avgwtSum = mean(epsilonP_wtSum(:));

h = ((hW / epsilonP_avgwtSum) .* epsilonP_wtSum) + prop.radiusPunch + prop.thicknessBlank;

punchLoad_MPa = pi() * (2 * prop.radiusPunch) * prop.thicknessBlank * prop.UTS * ((prop.radiusBlank / prop.radiusPunch) - 0.7);
punchLoad_tons = (punchLoad_MPa * (pi() * (prop.radiusPunch ^ 2))) / (9.81 * 1E3);

drawingRatio = prop.radiusBlank / prop.radiusPunch;

deltah = ((h(1)+ h(19))/2) - h(10);

avgh = (h(1)+ (2*h(10)) + h(19)) / 4;

pctEaring = (deltah /avgh) * 100;
%%


disp('---')
disp (['Predicted punch load     (MPa)                               = ', num2str(punchLoad_MPa)]);
disp (['Predicted punch load     (tons)                              = ', num2str(punchLoad_tons)]);
disp('---')
disp (['Drawing ratio            [blankDiameter : punchDiameter]     = ', num2str(drawingRatio)]);
disp('---')
disp (['Variation in cup height  [Delta h = ((h0 + h90) / 2) - h45]  = ', num2str(deltah)]);
disp (['Average cup height       [Avg h   = (h0 + 2*h45 + h90) / 4]  = ', num2str(avgh)]);
disp (['Total percentage earing  [(Delta h / Avg h) * 100]           = ',num2str(pctEaring),' %']);


end





function v = calcODFvolFraction(odf)
% Initialise variables
fg = odf.opt.intensity;

% Define odf extents
[maxRho,maxTheta,maxSec] = fundamentalRegionEuler(odf.SRight,odf.SLeft);

% Define the dimensions of the odf grid
x = linspace(0,maxTheta,size(fg,2));
y = linspace(0,maxRho,size(fg,1));
z = linspace(0,maxSec,size(fg,3));

% Create a meshgrid
[phi1, Phi, phi2] = meshgrid(x, y, z);
dphi1 = max(diff(phi1(:)),[],'all');
dPhi = max(diff(Phi(:)),[],'all');
dphi2 = max(diff(phi2(:)),[],'all');


% Initialise the grid of multiplier fractions with 1
multFrac = ones(size(phi1));

% Update the corner values of the grid of multiplier fractions with 1/8
multFrac([1 end], [1 end], [1 end]) = 1/8;

% Update the edge values of the grid of multiplier fractions with 1/4
multFrac([1 end], [1 end], 2:end-1) = 1/4;
multFrac([1 end], 2:end-1, [1 end]) = 1/4;
multFrac(2:end-1, [1 end], [1 end]) = 1/4;

% Update the end faces of the grid of multiplier fractions with 1/2
multFrac([1 end], 2:end-1, 2:end-1) = 1/2;
multFrac(2:end-1, [1 end], 2:end-1) = 1/2;
multFrac(2:end-1, 2:end-1, [1 end]) = 1/2;

% CHECK
% scatter3(phi1(:),Phi(:),phi2(:),50,multFrac(:),'filled');

% Calculate the ODF volume fraction
v = 1/((pi()^2)) .* multFrac .* odf.opt.intensity .* (cos(Phi -(dPhi/2)) - cos(Phi + (dPhi/2))) .* sin(Phi) .* (dphi1 * dphi2);

% Normalise the volume fraction
v = v ./ sum(v(:));

end