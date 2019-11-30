function [vol,dist] = volume(psi,radius,dist)

if nargin < 3
  N = 60;
  dist = zeros(numel(radius),N);
  for i = 1:length(radius)
        
    if radius(i) + 5 * psi.halfwidth < pi
      dist(i,1:N-9) = linspace(0,radius(i) + 5 * psi.halfwidth,N-9);
      dist(i,N-9:end) = linspace(radius(i) + 5 * psi.halfwidth,pi,10);
    else
      dist(i,:) = linspace(0,pi,N);
    end
    
  end

end

% make radius square as well
radius = repmat(radius(:),1,size(dist,2));

% weight function
weight = @(rot_angle,quat_dist,volume_radius) (max(0,min(4*pi,2*pi*(1-(cos(volume_radius/2) - ...
  cos(quat_dist/2) * cos(rot_angle/2))./...
  (sin(quat_dist/2) * sin(rot_angle/2))))) ...
  + max(0,min(4*pi,2*pi*(1-(cos(volume_radius/2) + ...
  cos(quat_dist/2) * cos(rot_angle/2))./...
  (sin(quat_dist/2) * sin(rot_angle/2))))))./pi./4;

% integrant
KV = @(rot_angle,quat_dist,volume_radius) weight(rot_angle,quat_dist,volume_radius) ...
  .* sin(rot_angle ./2).^2 .* psi.K(cos(rot_angle./2)) ./pi.*2 ;

% perform quadrature
%vol = zeros(size(dist));
%for j = 1:length(dist)
%  vol(j) = quad(@(rot_angle) KV(rot_angle,dist(j),radius),0,min(pi,5*k.hw),1e-6);
%end

vol = quadv(@(rot_angle) KV(rot_angle,dist,radius),0,min(pi,5*psi.halfwidth),1e-7);
%vol = integral(@(rot_angle) KV(rot_angle,dist,radius),0,min(pi,5*psi.halfwidth),'AbsTol',1e-7,'ArrayValued',true);
%'AbsTol',1e-7,
