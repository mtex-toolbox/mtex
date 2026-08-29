%% calcLankford uses CRSS-weighted plastic work

CS = crystalSymmetry('6/mmm',[3.2 3.2 5.2]);
sS = [slipSystem.basal(CS,1), ...
  slipSystem.prismatic2A(CS,4), ...
  slipSystem.pyramidalCA(CS,7)];
ori = orientation.byEuler(30*degree,45*degree,0*degree,CS);
rho = linspace(0,1,11);

[R,M,minM] = calcLankford(ori,sS,0,'rho',rho,'silent');
assert(isnull(R-1.5), ...
  'calcLankford must minimize CRSS-weighted work, not geometric M');

RD = xvector;
ND = zvector;
TD = cross(RD,ND);
eps = strainTensor(RD*RD) - rho .* strainTensor(TD*TD) ...
  - (1-rho) .* strainTensor(ND*ND);
work = calcTaylor(inv(ori)*eps,sS,'plasticWork','silent'); %#ok<MINV>
assert(max(abs(M(:)-work(:))) < 1e-10 && isnull(minM-min(work)), ...
  'calcLankford must return the normalized plastic-work curve and minimum');

%% Sheet directions are normalized and checked

Rscaled = calcLankford(ori,sS,0,vector3d(2,0,0),vector3d(0,0,3), ...
  'rho',rho,'silent');
assert(isnull(Rscaled-R),'non-unit RD and ND should be normalized');

try
  calcLankford(ori,sS,0,xvector,vector3d(1,0,1),'rho',rho,'silent');
  error('check_calcLankford:missingDirectionError', ...
    'Nonorthogonal RD and ND should have been rejected.');
catch ME
  assert(strcmp(ME.identifier,'MTEX:calcLankford:invalidSheetDirections'), ...
    'Unexpected error for nonorthogonal sheet directions: %s',ME.identifier);
end

try
  calcLankford(ori,sS,0,'rho',[-0.1 0.5 1],'silent');
  error('check_calcLankford:missingRhoError', ...
    'rho outside [0,1] should have been rejected.');
catch ME
  assert(strcmp(ME.identifier,'MTEX:calcLankford:invalidRho'), ...
    'Unexpected error for invalid rho: %s',ME.identifier);
end

%% Verbose summary reports normal and planar anisotropy separately

theta = [0 45 90] * degree;
summary = evalc('[Rv,~,~] = calcLankford(ori,sS,theta,''rho'',rho,''verbose'');');
Rbar = 0.25 * (Rv(1) + 2*Rv(2) + Rv(3));
deltaR = 0.5 * (Rv(1) - 2*Rv(2) + Rv(3));
assert(contains(summary,['Rbar = ',num2str(Rbar)]) && ...
  contains(summary,['deltaR = ',num2str(deltaR)]), ...
  'Verbose output must report the standard Rbar and deltaR formulas');

%#ok<*NASGU>
