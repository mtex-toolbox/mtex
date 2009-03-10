function [vol,dist] = volume(k,radius,dist)

if nargin < 3
  dist = linspace(0,min(pi,radius + 5 * k.hw),50);
  if dist(end) < pi
    dist = [dist(1:end-1),linspace(dist(end),pi,10)];
  end
end

%% weight function
weight = @(rot_angle,quat_dist,volume_radius) (max(0,min(4*pi,2*pi*(1-(cos(volume_radius/2) - ...
  cos(quat_dist/2) * cos(rot_angle/2))./...
  (sin(quat_dist/2) * sin(rot_angle/2))))) ...
  + max(0,min(4*pi,2*pi*(1-(cos(volume_radius/2) + ...
  cos(quat_dist/2) * cos(rot_angle/2))./...
  (sin(quat_dist/2) * sin(rot_angle/2))))))./pi./4;

%% integrant
KV = @(rot_angle,quat_dist,volume_radius) weight(rot_angle,quat_dist,volume_radius) ...
  .* sin(rot_angle ./2).^2 .* k.K(cos(rot_angle./2)) ./pi.*2 ;

%% perform quadrature
vol = zeros(size(dist));
for j = 1:length(dist)
  vol(j) = quadv(@(rot_angle) KV(rot_angle,dist(j),radius),0,min(pi,5*k.hw));
end
