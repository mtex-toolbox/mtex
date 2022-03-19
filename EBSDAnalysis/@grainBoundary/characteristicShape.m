function [cshape, xyn] = characteristicShape(gb)
% derive characteristic shape from a set of grain boundaries
%
% % Syntax
%   cshape = characteristicShapeN(grains.boundary('b','b'))
%   plotTDF(cshape(:,1),cshape(:,2))
%
% Input
%  gb   -  @grainBoundary 
%
% Output
%  cshape - polar coordinates of characteristic shape
%  xyn    - x,y coordiantes of characteritic shape
%


% xy coordinates shifted to originate at 0
xy = gb.V(gb.F(:,2),:) - gb.V(gb.F(:,1),:);

% just consider one direction
fcond = xy(:,2)<0;
xy(fcond,:)=xy(fcond,:).*-1;
dxy = [xy; -xy];

% sort segments according to angle
[~,id]= sort(atan2(dxy(:,2),dxy(:,1)));
dxy = dxy(id,:);

% sum up
xyn = cumsum(dxy);

% shift again
xyn = [xyn(:,1) - mean(xyn(:,1)) xyn(:,2) - mean(xyn(:,2))];

% output
cshape = [atan2(xyn(:,2),xyn(:,1))  ...
          sqrt(xyn(:,2).^2 + xyn(:,1).^2)];
end