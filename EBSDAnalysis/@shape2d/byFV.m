function  shape = byFV(F,V,varargin)
% Define shape2d by a list of segments and vertices
%
% Syntax
%
%   cShape = characteristicShape.byVF(F,V)
%
% Input
%  F - azimuth angle / bin center
%  V - radius / bin population
%
% Output
%  cShape - @shape2d
%

% xy coordinates shifted to originate at 0
seg = V(F(:,2),:) - V(F(:,1),:);

% the normal direction to the segments
[~,ind] = max(norm(seg));
[~,ind2] = max(angle(seg,seg(ind)));
N = cross(seg(ind),seg(ind2));

% consider also antipodal direction
seg = [seg; -seg];

% sort segments according to angle to the largest segment
[~,id]= sort(angle(seg,seg(ind),N));
seg = seg(id,:);

% sum up
Vnew = cumsum(seg);

% shift again
Vnew = Vnew - mean(Vnew);

% simplify
if ~check_option(varargin,'noSimplify')
  id = floor(linspace(1,length(Vnew),1024));
  Vnew = Vnew(id,:);
end

shape = shape2d(Vnew);

end