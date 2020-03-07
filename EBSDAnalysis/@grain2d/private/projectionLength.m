function pl = projectionLength(Vg,varargin)
% Returns the projection length of a group of vertices as a function
% of angle omega. omega=0 gives the projection length against the
% x.
%
% Syntax:
%  Vg = grains(1).V(grains(1).poly{1},:) % vertices of the first grain
%  pl = projectionLength(Vg,[0:10:179]*degree)
%
% Input:
%  Vg     - list of vertices for a sngle grain
%  omegaP - list of angles (default 0:pi-1*degree in 1 degree steps)
%
% Output:
%  pl     - list of projection lengths as a function of omegaP


if nargin>1 && isnumeric(varargin{1})
    omegaP=varargin{1};
else
    omegaP=[0:1:179]*degree;
end
pl = zeros(length(omegaP),1);
% rotate everything
% TODO: maybe omit this loop adn the rotation matrix
for j=1:length(omegaP)
    VgR = [cos(omegaP(j)) sin(omegaP(j)); -sin(omegaP(j)) cos(omegaP(j))]*Vg';
    pl(j)=max(VgR(1,:))-min(VgR(1,:)); % projection length
end
end
