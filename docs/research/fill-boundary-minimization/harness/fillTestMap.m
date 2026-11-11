function [ebsd,info] = fillTestMap(name,varargin)
% synthetic square-grid EBSD map with a notIndexed pocket or crack of known minimal boundary
%
% Syntax
%   [ebsd,info] = fillTestMap('disc3')
%   [ebsd,info] = fillTestMap('crack2','R',18,'size',128)
%
% Input
%  name - 'disc2', 'disc2oblique', 'disc3', 'disc4', 'crack2', 'crackAcross', 'island', 'Lpocket'
%
% Options
%  R    - size parameter of the hole (default 12)
%  size - side of the map in pixels (default 96)
%
% Output
%  info.grainId   - true grain id of every pixel, also of the notIndexed ones
%  info.hole      - pixels set notIndexed
%  info.Lopt      - minimal length of the boundary network inside the hole, NaN if not known
%  info.terminals - k x 2, where the grain boundaries enter the hole, in ebsd.pos coordinates
%  info.opt       - calcGrains options that fill the hole
%  info.Lstar     - 'disc4' only: the best network with a single quadruple point
%
% The geometry below uses X = j, Y = i for pixel (i,j). EBSDsquare places
% that pixel at ebsd.pos = (j-1, i-1), so the terminals are shifted by -1.

R = get_option(varargin,'R',12);
n = get_option(varargin,'size',96);
c = n/2 + 0.5;
[X,Y] = meshgrid(1:n,1:n);
disc = @(r) (X-c).^2 + (Y-c).^2 <= r^2;
hw = R; Lopt = NaN; info = struct;

switch name
  case 'disc2'
    gid = 1 + (X > c); hole = disc(R);
    Lopt = nnz(any(hole(:,floor(c):ceil(c)),2));
  case 'disc2oblique'
    gid = 1 + ((Y-c) <= 3*(X-c)); hole = disc(R);
  case 'disc3'
    gid = (Y > c) + (Y < c).*(2 + (X > c)); hole = disc(R);
  case 'disc4'
    gid = 1 + (X > c) + 2*(Y > c); hole = disc(R);
  case 'crack2'
    w = max(3,round(R/3)); hw = w/2;
    d = [sind(30) cosd(30)];
    gid = 1 + (X > c);
    hole = segDist(X,Y,[c c]-2*R*d,[c c]+2*R*d) <= hw;
  case 'crackAcross'
    w = 2*round(R/2); hw = w/2;
    gid = 1 + (Y > c-16) + (Y > c+16);
    hole = abs(X-c) < hw & Y > 8 & Y <= n-8;
    Lopt = 2*w;
  case 'island'
    % minimal network: two triple junctions on the island plus the boundary around the island
    hw = max(R,10); isl = abs(X-c) < 2 & abs(Y-c) < 2;
    gid = 1 + (X > c); gid(isl) = 3;
    hole = disc(hw) & ~isl;
  case 'Lpocket'
    w = max(4,round(R/2)); hw = w/2;
    gid = 2 - ((Y < c & X < c) | (Y > c & X < c+R));
    hole = min(cat(3,segDist(X,Y,[c c-2*R],[c c]), segDist(X,Y,[c c],[c+R c]), ...
      segDist(X,Y,[c+R c],[c+R c+2*R])),[],3) <= hw;
  otherwise
    error('fillTestMap: unknown map ''%s''',name);
end

T = terminals(gid,hole);
switch name
  case {'disc2oblique','crack2'}
    Lopt = norm(diff(T));
  case 'disc3'
    Lopt = steiner3(T);
  case 'disc4'
    Lopt = steiner4(T);
    info.Lstar = sum(vecnorm(T - weiszfeld(T,mean(T),1000),2,2));
end

% phase 1 is notIndexed, phase 2 the cubic phase, as in EBSDGrainBenchmark
CS = crystalSymmetry('cubic');
k = (1:max(gid(:))).';
ori = rotation.byEuler(k*25*degree,k*17*degree,k*9*degree);
phaseId = 2*ones(n*n,1);
phaseId(hole) = 1;
ebsd = EBSDsquare([],ori(gid),phaseId,[0 1],{'notIndexed',CS},'dxy',[1 1]);
ebsd.prop.trueGrainId = gid(:);

r = ceil(hw) + 2;
info.grainId = gid;
info.hole = hole;
info.Lopt = Lopt;
info.terminals = T;
info.opt = {'alpha',r,'alphaPocket',r,'alphaCrack',r};

end

function d = segDist(X,Y,P,Q)
% distance of the points (X,Y) to the segment PQ
v = Q - P;
t = min(max(((X-P(1))*v(1) + (Y-P(2))*v(2)) / (v*v.'),0),1);
d = hypot(X - P(1) - t*v(1), Y - P(2) - t*v(2));
end

function T = terminals(gid,hole)
% lattice corners touching a hole pixel and non-hole pixels of two grains
box = @(M) conv2(double(M),ones(2),'valid') > 0;
nG = zeros(size(gid)-1);
for k = 1:max(gid(:)), nG = nG + box(gid == k & ~hole); end
[i,j] = find(box(hole) & nG >= 2);
P = [j i] + 0.5;

% corners closer than 4 pixels belong to one entry point, take their mean
S = zeros(0,2); m = zeros(0,1);
for r = 1:size(P,1)
  k = find(vecnorm(S./m - P(r,:),2,2) < 4,1);
  if isempty(k), S(end+1,:) = P(r,:); m(end+1,1) = 1; %#ok<AGROW>
  else, S(k,:) = S(k,:) + P(r,:); m(k) = m(k) + 1;
  end
end
T = S./m - 1;
end

function x = weiszfeld(P,x,nIter)
% geometric median of the rows of P, starting at x
for it = 1:nIter
  w = 1 ./ max(vecnorm(P - x,2,2),1e-12);
  x = sum(w.*P,1) / sum(w);
end
end

function L = steiner3(T)
% Steiner tree of three points, a vertex with an angle >= 120 degrees is the Fermat point
for k = 1:3
  u = T(mod(k,3)+1,:) - T(k,:); v = T(mod(k+1,3)+1,:) - T(k,:);
  if dot(u,v) <= -0.5*norm(u)*norm(v), L = norm(u) + norm(v); return; end
end
L = sum(vecnorm(T - weiszfeld(T,mean(T),1000),2,2));
end

function L = steiner4(T)
% shortest tree with two Steiner points s, t over all pairings, by alternating Weiszfeld
L = inf;
for p = [1 2 3 4; 1 3 2 4; 1 4 2 3].'
  A = T(p(1:2),:); B = T(p(3:4),:);
  s = mean(A); t = mean(B);
  for it = 1:2000
    s = weiszfeld([A; t],s,1);
    t = weiszfeld([B; s],t,1);
  end
  L = min(L, sum(vecnorm(A - s,2,2)) + norm(s - t) + sum(vecnorm(B - t,2,2)));
end
end
