function plotebsd(ebsd,varargin)
% scatter / pole point plot of ebsd data
%
% Input
%  ebsd - @EBSD
%
% Options
%  scatter | Rodrigues - plot orientations in axis/angle or rodrigues
%                        parametrization
%  points        - number of orientations to be plotted
%  center        - orientation center
%
% Example
% 
%   mtexdata aachen
%   plotebsd(ebsd('Fe'),'scatter')
%
% See also
% EBSD/plotpdf EBSD/scatter savefigure

[ax,ebsd,varargin] = getAxHandle(ebsd,varargin{:});

if length(ebsd) > 2000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',2000));
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(length(ebsd)),' given orientations']);
  ebsd = subSample(ebsd,points);
end

% compute center
if ~check_option(varargin,'center')
  varargin = {varargin{:},'center',mean(ebsd)};
end

plot(ax{:},ebsd.orientations,varargin{:});
