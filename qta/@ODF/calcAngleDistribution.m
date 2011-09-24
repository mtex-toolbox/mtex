function [density,omega] = calcAngleDistribution(odf,varargin)
% compute the angle distribution of an ODF or an MDF 
%
%
%% Input
%  odf - @ODF
%  omega - list of angles
%
%% Flags
%  EVEN       - calculate even portion only
%
%% Output
%  x   - values of the axis distribution
%
%% See also


% get resolution
points = get_option(varargin,'points',100000);
res = get_option(varargin,'resolution',2.5*degree);

if check_option(varargin,'integration')
  
  % the angle distribution of the uniformODF
  [density,omega] = angleDistribution(get(odf,'CS'));

  % for all angles
  for k=1:numel(omega)  
    
    S2G = S2Grid('equispaced','points',max(1,round(4/3*sin(omega(k)/2).^2/res^2))); % create a grid
        
    % create orientations
    o = axis2quat(S2G,omega(k));
    
    % and select those
    angle = abs(dot_outer(o,get(odf,'CS')));
    maxAngle = max(angle,[],2); 
        
    % the angel frequency
    %sum(angle(:,1)>maxAngle-0.0001)
    if any(angle(:,1)>maxAngle-0.0001)
      density(k) = density(k) * mean(eval(odf,o(angle(:,1)>maxAngle-0.0001)));  %#ok<EVLC>
    end
  end
  
else
      

  %% simluate EBSD data
  ebsd = calcEBSD(odf,points,'resolution',res);

  % compute angles
  angles = angle(get(ebsd,'orientations'));

  maxangle = max(angles);


  %% perform kernel density estimation

  [bandwidth,density,omega,cdf] = kde(angles,2^8,0,maxangle);

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
