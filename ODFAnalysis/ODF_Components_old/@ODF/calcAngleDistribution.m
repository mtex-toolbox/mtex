function [density,omega] = calcAngleDistribution(odf,varargin)
% compute the angle distribution of an ODF or an MDF 
%
% Input
%  odf - @ODF
%  omega - list of angles
%
% Flags
%  even       - calculate even portion only
%
% Output
%  x   - values of the axis distribution
%
% See also

if nargin > 1 && isa(varargin{1},'ODF')
  odf = calcMDF(odf,varargin{1});
  varargin(1) = [];
end

if ~check_option(varargin,'fast')

  % get resolution
  res = get_option(varargin,'resolution',0.5*degree);
  
  % initialize evaluation grid
  S3G = quaternion;
  iS3G = 0;
  cs1 = odf.CS;
  cs2 = odf.SS;
  csD = properGroup(disjoint(cs1,cs2));
  
  % the angle distribution of the uniformODF
  if check_option(varargin,'omega')
    omega = get_option(varargin,'omega',[]);
    density = zeros(size(omega));
    d = calcAngleDistribution(cs1,cs2,omega); 
    density(1:numel(d)) = d;
  else
    [density,omega] = calcAngleDistribution(cs1,cs2);
  end
  
  sR = csD.fundamentalSector;

  % for all angles
  for k=1:numel(omega)  
    
    S2G = equispacedS2Grid('points',max(1,round(4/3*sin(omega(k)/2).^2/res^2)),...
      sR,'RESTRICT2MINMAX'); % create a grid  TODO

    %S2G = S2Grid('random','points',max(1,numel(csD)*round(4/3*sin(omega(k)/2).^2/res^2)),...
    %  'minTheta',minTheta,'MAXTHETA',maxTheta,'MAXRHO',maxRho,'MINRHO',minRho,'RESTRICT2MINMAX'); % create a grid
    
    % create orientations
    o = axis2quat(S2G(:),omega(k));
    
    % and select those
    rotAngle = abs(dot_outer(o,odf.CS.rot));
    maxAngle = max(rotAngle,[],2); 
    o = o(rotAngle(:,1)>maxAngle-0.0001);
    
    % store these orientations
    S3G = [S3G;o]; %#ok<AGROW>
    iS3G(k+1) = length(S3G); %#ok<AGROW>
    
  end
  
  % evaluate the ODF at the grid
  f = max(0,eval(odf,S3G));
  
  % integrate
  for k = 1:numel(omega)    
    if iS3G(k)<iS3G(k+1)
      density(k) = density(k) * mean(f(iS3G(k)+1:iS3G(k+1)));
    end
  end
  
else
      

  % get resolution
  points = get_option(varargin,'points',100000);
  
  % get resolution
  res = get_option(varargin,'resolution',2.5*degree);
  
  % simluate EBSD data
  ori = calcOrientations(odf,points,'resolution',res);

  % compute angles
  angles = ori.angle;

  maxangle = max(angles);

  % perform kernel density estimation
  [bandwidth,density,omega] = kde(angles,2^8,0,maxangle,'magicNumber',0.28); %#ok<ASGLU>

  density = density ./ mean(density) * pi ./ maxangle;
  
end

% where to evaluate
%omega = linspace(0,maxangle,100);

% 
%sigma = 20;
%psi = @(a,b) exp(-(a-b).^2*sigma.^2);

%
%x = sum(bsxfun(psi,angles,omega));
%x = x./sum(x)*numel(x);
