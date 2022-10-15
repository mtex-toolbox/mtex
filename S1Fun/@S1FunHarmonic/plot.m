function h = plot(sF,varargin)
% plot a S1Fun
%
% Syntax
%   N = vector3d.Z; % normal direction
%   plotSection(sF,N) % plot in equator plane
%
%   theta = pi/3;   % polar angle 
%   plotSection(sF,N,theta) % plot small circle at 30 degree from the north pole
%
%   rho = linspace(0,pi); % azimuthal angle
%   plotSection(sF,N,theta,rho) % plot half small circle at 30 degree
%
% Input
%  sF - @S1Fun
%
% Output
%
%
 
omega = linspace(0,2*pi,361);

d = real(sF.eval(omega));

h = polarplot(omega,d,varargin{:});

