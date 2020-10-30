function pl = projectionLength(Vg,varargin)
% Returns the projection length of a group of vertices as a function
% of angle omega. omega=0 gives the projection length against the
% x.
%
% Syntax:
%  Vg = grains(1).V(grains.poly{1},:) % vertices of the first grain
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
    omegaP = 0:1:179 * degree;
end

% omega x vetices
d = cos(omegaP(:)) * Vg(:,1).' + sin(omegaP(:)) * Vg(:,2).';

% max for each omega
pl = max(d,[],2)-min(d,[],2);

end
