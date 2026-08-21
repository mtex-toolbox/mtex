function [h,ax] = plot(sR,varargin)
% plots a spherical region
%
% This function is called by all spherical plot methods to plot the outer
% boundary and adjust the axes limits properly.
%

[mtexFig,isNew] = newMtexFigure(varargin{:});

% initialize spherical plots
sP = newSphericalPlot(sR,varargin{:});

h = gobjects(numel(sP),1);
for j = 1:numel(sP)

  % ensure sector is at this hemisphere TODO
  %if any(any(dot_outer(sR.N,sP(j).sphericalRegion.N)<eps-1)), continue, end

  %if all(sR.checkInside(sP(j).sphericalRegion.N)) && ~isempty(sP(j).boundary)
  if ~isempty(sP(j).boundary) && sR == sP(j).sphericalRegion
    varargin = delete_option(varargin,'parent',1);
    h = optiondraw(sP(j).boundary,varargin{:});
    continue;
  end

  % plot the region - build, clip and project the bounding circles in one go
  [X,Y] = boundaryPolygons(sR,sP(j).proj);

  varargin = delete_option(varargin,'parent',1);
  for i = 1:size(X,1)

    h(i) = optiondraw(line('xdata',X(i,:),'ydata',Y(i,:),'parent',sP(j).ax,...
      'color',[0.2 0.2 0.2],'linewidth',1.5,'hitTest','off'),varargin{:});

    % do not display in the legend
    h(i).Annotation.LegendInformation.IconDisplayStyle = "off";

  end
end

% give handles back
if nargout == 0
  clear h;
else
  ax = [sP.ax];
end

if isNew, mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); end

end

% -------------------------------------------------------------------------

function [x,y] = boundaryPolygons(sR,proj)
% the bounding circles of a region as projected, clipped polygons - one per
% row, the part outside the region replaced by NaN
%
% A circle is drawn as a polygon and clipped by dropping the points outside
% the region. The polygon itself is smooth at a fraction of a degree - what
% used to demand 8641 points per circle is the corner such a clip cuts,
% since the arc ends at the last sample inside rather than at the boundary.
% Sampling coarsely and moving those samples onto the boundary by bisection
% is both cheaper and more accurate than any uniform grid.
%
% Every circle is parametrized in an orthonormal basis of its own plane, so
% that a point costs two cosines and a linear combination - rotating a
% vector by a list of quaternions gives the same points, but builds a
% rotation per point.

n = normalize(sR.N(:));
u = orth(n); w = cross(n,u);
alpha = reshape(sR.alpha,[],1); r = sqrt(1-alpha.^2);

omega = linspace(0,2*pi,361);
x = alpha .* n + r .* (cos(omega) .* u + sin(omega) .* w);
inside = sR.checkInside(x);

% the samples right before a crossing - the polygon is closed, its first
% and its last point coincide, so no crossing is reported at the seam
[i,c] = find(inside ~= inside(:,[2:end,1]));
i = i(:); c = c(:);

if ~isempty(i)

  % move the sample outside the region, and every crossing has to claim a different one
  isLo = inside(sub2ind(size(inside),i,c));
  ind = sub2ind(size(inside),i,c + double(isLo));
  [~,firstOfInd] = unique(ind,'stable');
  claimed = false(size(ind)); claimed(firstOfInd) = true;
  keep = claimed & ~ismember(ind,ind(~claimed));

  i = i(keep); c = c(keep); isLo = isLo(keep); ind = ind(keep);

  % bisect all crossings onto the boundary at once
  lo = omega(c).'; hi = omega(c+1).';
  ni = n(i); ui = u(i); wi = w(i); ai = alpha(i); ri = r(i);
  for k = 1:12 % 12 halvings of a degree - far below a pixel
    mid = (lo+hi)/2;
    atLo = sR.checkInside(ai.*ni + ri.*(cos(mid).*ui + sin(mid).*wi)) == isLo;
    lo(atLo) = mid(atLo); hi(~atLo) = mid(~atLo);
  end

  % take the end that is inside, so the point stays in the region
  bnd = hi; bnd(isLo) = lo(isLo);
  x(ind) = ai.*ni + ri.*(cos(bnd).*ui + sin(bnd).*wi);
  inside(ind) = true;

end

[x,y] = project(proj,x,'noAntipodal');
x(~inside) = NaN;

end
