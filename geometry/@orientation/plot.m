function plot(o,varargin)
% plot function
%
% Input
%  o - @orientation
%
% Options
%  RODRIGUES - plot in rodrigues space
%  AXISANGLE - plot in axis / angle
%
% See also
% orientation/scatter Plotting

newMTEXplot;

if ~(ishold(gca) && strcmp(get(gca,'tag'),'ebsd_raster')) && ...
    ~check_option(varargin,{'scatter','rodrigues','axisangle'})

  washold = ishold(gca);
  hold(gca,'all')
  for i = 1:length(o)

    h = [Miller(1,0,0,o.CS),Miller(0,1,0,o.CS),Miller(0,0,1,o.CS)];
    plot(subsref(o,i) * h,'label',...
      char(h,getMTEXpref('textInterpreter'),'cell'),...
      varargin{:});
  end

  if ~washold, hold(gca,'off');end

else % scatter plot

  scatter(o,varargin{:});

end
