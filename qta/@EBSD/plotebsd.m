function plotebsd(ebsd,varargin)
% plots ebsd data
%
%% Syntax
% plotebsd(ebsd,<options>)
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  POINTS        - number of orientations to be plotted
%  CENTER        - orientation center
%
%% See also
% EBSD/plotpdf savefigure

if sum(sampleSize(ebsd)) > 2000 || check_option(varargin,'points')
  points = get_option(varargin,'points',2000);
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(sum(sampleSize(ebsd))),' given orientations']);
  ebsd = subsample(ebsd,points);
end

%% compute center

if ~check_option(varargin,'center')
  varargin = {varargin{:},'center',mean(ebsd)};
end

plot(get(ebsd,'orientations'),varargin{:});
