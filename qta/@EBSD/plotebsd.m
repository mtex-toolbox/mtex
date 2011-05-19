function plotebsd(ebsd,varargin)
% scatter / pole point plot of ebsd data
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  SCATTER | RODRIGUES - plot orientations in axis/angle or rodrigues
%                        parametrization
%  POINTS        - number of orientations to be plotted
%  CENTER        - orientation center
%
%% Example
% 
%   mtexdata aachen
%   plotebsd(ebsd,'phase',1,'scatter')
%
%% See also
% EBSD/plotpdf EBSD/scatter savefigure

if sum(sampleSize(ebsd)) > 2000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',2000));
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(sum(sampleSize(ebsd))),' given orientations']);
  ebsd = subsample(ebsd,points);
end

%% compute center

if ~check_option(varargin,'center')
  varargin = {varargin{:},'center',mean(ebsd)};
end

plot(get(ebsd,'orientations'),varargin{:});
