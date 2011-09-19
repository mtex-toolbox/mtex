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


if check_option(varargin,'integration')
  
  
  CS = get(odf,'CS');
  
  % the rotational angles and angle distribution of the uniformODF
  [density,omega] = angleDistribution(CS);

  S2G = S2Grid('equispaced','points',72*19*16); % create a grid
  S2G = rotate(S2G,axis2quat(yvector,90*degree));

  S2G = delete_option(S2G,'indexed');
      
  % for all angles
  for k=1:numel(omega)  
    
    % create a orientation ball
    o = axis2quat(S2G,omega(k)); 
    
    [d,zone] = max(abs(dot_outer(o,CS)),[],2); % and select those
        
    % the angel frequency
    if any(zone==1)
      density(k) = density(k) * mean(eval(odf,o(zone==1)));  %#ok<EVLC>
    end
  end
  
end

  
else
  
  

% get resolution
points = get_option(varargin,'points',100000);
res = get_option(varargin,'resolution',2.5*degree);

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
