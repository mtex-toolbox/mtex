function [V, F, L, labPos, labStr, bbox] = refFrameGeometry(rfScreen, labels, t)
% geometry of the reference frame indicator, in screen relative coordinates
% around its own origin - u to the right, v upwards, both unsigned
%
% The one drawing of a reference frame in MTEX: an arrow per axis that has
% a direction on screen with its name beyond the head, and the name of the
% axis along the view at the crossing the arrows leave from - a right handed
% frame needs no symbol to tell out of the screen from into it. @scaleBar
% puts it in the corner of a map, the import wizard draws its pictograms
% with it.
%
% Input
%  rfScreen - n × 3 matrix of the (right, up, outOfScreen) components
%  labels   - cell of char, one per direction
%  t        - the measured text height, used as the length unit
%
% Output
%  V, F     - vertices and faces of the arrows, one polygon each
%  L        - empty, there is no line work
%  labPos   - n × 2 label positions, NaN for directions that are not drawn
%  labStr   - the labels belonging to them
%  bbox     - [minU maxU minV maxV] of everything drawn

e         = 0.8*t;          % the font size, a text is about 1.25 of it high
arm       = 2.55*e;         % length of a full length arrow
headLen   = 0.78*e;
shaftHalf = 0.125*e;        % half width of the arrow shaft
headHalf  = 0.27*e;         % half width of the arrow head
gap       = 0.45*e;         % between a name and the arrow it belongs to

% half the ink box of a name, and how far it reaches along a direction d
box = @(s) [0.31*max(1,numel(s)), 0.36] * e;
reach = @(b,d) b(1)*abs(d(1)) + b(2)*abs(d(2));

n = size(rfScreen,1);
labStr = repmat({''},1,n);
labStr(1:min(n,numel(labels))) = labels(1:min(n,numel(labels)));
labPos = nan(n,2);

% draw an arrow only when the direction is more than about 9 degree off the view
inPlane = hypot(rfScreen(:,1),rfScreen(:,2)) >= 0.15;

% the axis along the view is named at the crossing, the arrows start clear of it
kOut = find(~inPlane,1);
hub = [0 0];
if ~isempty(kOut)
  labPos(kOut,:) = [0 0];
  hub = box(labStr{kOut});
end

V = zeros(0,2);
for k = reshape(find(inPlane),1,[])

  % the arrow is shortened by the projection, so that a direction tilted
  % away from the screen plane reads as such
  d = rfScreen(k,1:2);
  s0 = gap + reach(hub, d ./ norm(d));
  tip = s0 + max(norm(d)*(arm - gap), headLen);
  d = d ./ norm(d);
  p = [-d(2), d(1)]; % normal to the arrow
  b = tip - headLen;

  V = [V; ...
    s0*d + shaftHalf*p; ...
    b*d + shaftHalf*p; ...
    b*d + headHalf*p; ...
    tip*d; ...
    b*d - headHalf*p; ...
    b*d - shaftHalf*p; ...
    s0*d - shaftHalf*p]; %#ok<AGROW>

  labPos(k,:) = (tip + gap + reach(box(labStr{k}), d)) * d;
end

if isempty(V)
  V = [NaN NaN]; F = 1;
else
  F = reshape(1:size(V,1), 7, []).';
end
L = zeros(0,2);

% the tight bounding box of arrows, labels and the origin - an unlabelled
% direction reserves no room
labPos(cellfun(@isempty,labStr),:) = NaN;
half = cell2mat(cellfun(box, labStr(:), 'UniformOutput', false));
P = [V; labPos - half; labPos + half; 0 0];
P(any(isnan(P),2),:) = [];
bbox = [min(P(:,1)), max(P(:,1)), min(P(:,2)), max(P(:,2))];

end
