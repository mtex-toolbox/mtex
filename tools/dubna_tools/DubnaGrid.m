function r = DubnaGrid(ntheta)
% construct specimen grid of the Dubna goniometer

theta = linspace(0,pi/2,19);
theta = theta(1:ntheta);
theta = repmat(theta,72,1);
rho   = linspace(0,2*pi,72);
rho   = repmat(rho.',1,ntheta);
% the strating angles of rho beginning with theta = 0;
rhostart = fliplr([360.00,336.40,327.05,320.11,314.44,309.57,305.26,301.37,297.80,...
	294.47,291.34,288.38,285.54,282.81,280.16,277.57,275.02,272.50,270.00])*pi/180;
rhostart = repmat(rhostart(1:ntheta),72,1);
rho = rhostart + rho;
r = vector3d.byPolar(theta,rho,'antipodal','RESOLUTION',5*degree);
