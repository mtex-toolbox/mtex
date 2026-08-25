function [V, F, L, labPos, labStr, bbox] = refFrameGeometry(rfScreen, labels, t)
% geometry of the reference frame indicator, in screen relative coordinates
% around its own origin - u to the right, v upwards, both unsigned
%
% The one drawing of a reference frame in MTEX: an arrow per axis that has
% a direction on screen, a circled dot or cross for the one that points out
% of or into it, and a label per axis. @scaleBar puts it in the corner of a
% map, the import wizard shows the same picture for the map and the Euler
% coordinate systems it offers.
%
% Input
%  rfScreen - n × 3 matrix of the (right, up, outOfScreen) components
%  labels   - cell of char, one per direction
%  t        - the measured text height, used as the length unit
%
% Output
%  V, F     - vertices and faces of everything filled: the arrows and, if
%             present, the dot of the out of screen symbol. The faces
%             differ in length, hence F is NaN padded
%  L        - polyline of the circle and, for a direction pointing into the
%             screen, of the cross inside it
%  labPos   - n × 2 label positions, NaN for directions that are not drawn
%  labStr   - the labels belonging to them
%  bbox     - [minU maxU minV maxV] of everything drawn

arm       = 1.2*t;          % length of a full length arrow
shaftHalf = t/8;            % half width of the arrow shaft
headHalf  = 3*shaftHalf;    % half width of the arrow head
headLen   = 0.3*arm;
symR      = 0.32*arm;       % radius of the out of screen circle
pad       = 0.55*t;         % distance between an arrow tip and its label
% estimated half extent of a label, growing with the longest label - the
% frame axes names may be two letters, RD or X1
maxLen    = max([1,cellfun(@numel,labels)]);
labHalf   = [(0.15 + 0.25*maxLen)*t, 0.5*t];

n = size(rfScreen,1);

% draw an arrow only when the direction is more than about 9 degree off the view
inPlane = hypot(rfScreen(:,1),rfScreen(:,2)) >= 0.15;

V = zeros(0,2); L = zeros(0,2); faceIdx = {};
labPos = nan(n,2); labStr = repmat({''},1,n);

% draw the out of screen symbol first, the arrows have to start outside of it
kSym = find(~inPlane,1);
if isempty(kSym)
  r0 = 0;
else
  r0 = 1.3*symR;

  phi = linspace(0,2*pi,49).';
  L = symR * [cos(phi), sin(phi)];

  if rfScreen(kSym,3) > 0
    psi = linspace(0,2*pi,13).'; psi(end) = [];
    V = [V; 0.35*symR * [cos(psi), sin(psi)]];
    faceIdx{end+1} = size(V,1)-11 : size(V,1);
  else
    r = symR/sqrt(2);
    L = [L; NaN NaN; -r -r; r r; NaN NaN; -r r; r -r];
  end
end

for k = reshape(find(inPlane),1,[])

  % the arrow is shortened by the projection, so that a direction tilted
  % away from the screen plane reads as such
  d = rfScreen(k,1:2);
  len = norm(d)*arm;
  d = d ./ norm(d);
  p = [-d(2), d(1)]; % normal to the arrow

  % keep the head from swallowing a strongly foreshortened arrow
  hl = min(headLen, 0.6*len);

  V = [V; ...
    r0*d + shaftHalf*p; ...
    (r0+len-hl)*d + shaftHalf*p; ...
    (r0+len-hl)*d + headHalf*p; ...
    (r0+len)*d; ...
    (r0+len-hl)*d - headHalf*p; ...
    (r0+len-hl)*d - shaftHalf*p; ...
    r0*d - shaftHalf*p]; %#ok<AGROW>
  faceIdx{end+1} = size(V,1)-6 : size(V,1); %#ok<AGROW>

  labPos(k,:) = (r0 + len + pad)*d;
  if k <= numel(labels), labStr{k} = labels{k}; end

end

if ~isempty(kSym)

  % place the label of the circled symbol away from the arrows, so that it
  % can never sit on one
  inP = rfScreen(inPlane,1:2);
  d = -sum(inP ./ hypot(inP(:,1),inP(:,2)), 1);
  if norm(d) < 1e-6, d = [-1 -1]/sqrt(2); else, d = d ./ norm(d); end

  labPos(kSym,:) = (symR + 0.75*pad)*d;
  if kSym <= numel(labels), labStr{kSym} = labels{kSym}; end

end

if isempty(faceIdx)
  V = [NaN NaN]; F = 1;
else
  F = nan(numel(faceIdx),max(cellfun(@numel,faceIdx)));
  for k = 1:numel(faceIdx), F(k,1:numel(faceIdx{k})) = faceIdx{k}; end
end

% the tight bounding box of arrows, symbol, labels and the origin - an
% unlabelled direction reserves no room
labPos(cellfun(@isempty,labStr),:) = NaN;
P = [V; L; labPos - labHalf; labPos + labHalf; 0 0];
P(any(isnan(P),2),:) = [];
bbox = [min(P(:,1)), max(P(:,1)), min(P(:,2)), max(P(:,2))];

end
