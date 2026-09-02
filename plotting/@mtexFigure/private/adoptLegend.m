function changed = adoptLegend(mtexFig)
% take over a legend that has been asked to sit outside the axes
%
% MATLAB keeps such a legend glued to its peer axes by shrinking that axes
% whenever the legend is laid out. mtexFigure computes the axes position
% itself and hands the axes the full figure again - the two layout managers
% then push against each other and where the legend ends up depends on how
% many resize events happened in between, which is why the same plot came
% out differently on every run.
%
% Taking the legend over settles this: we remember which side it was asked
% for, from then on reserve a band for it and position it ourselves.
% Assigning a Position switches the legend to manual placement, so MATLAB
% stops resizing the axes behind our back. Legends inside the axes are left
% alone.
%
% Output
%  changed - whether the adopted legend changed, i.e. the tight inset has to
%            be recomputed

old = mtexFig.legendAxis;
if ~all(isgraphics(old)), old = gobjects(0,1); end % deleted meanwhile

new = old;
side = mtexFig.legendSide;

if isempty(new)
  % a legend is a direct child of the figure - searching only that level
  % keeps this cheap, as it runs on every layout, i.e. on every resize
  lg = findobj(mtexFig.parent,'-depth',1,'Type','legend');
  for k = 1:numel(lg)
    loc = char(lg(k).Location);
    if ~endsWith(loc,'outside'), continue; end

    new = lg(k);

    % 'northeastoutside' sits east of the axes, 'northoutside' above it
    if contains(loc,'east')
      side = 'east';
    elseif contains(loc,'west')
      side = 'west';
    elseif contains(loc,'north')
      side = 'north';
    else
      side = 'south';
    end
    break
  end
end

changed = ~isequal(old,new) || ~strcmp(side,mtexFig.legendSide);

if changed
  % all legend geometry below is computed in pixels
  if ~isempty(new), set(new,'Units','pixels'); end
  mtexFig.legendAxis = new;
  mtexFig.legendSide = side;
end

end
