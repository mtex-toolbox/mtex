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
%
%% See also
% EBSD/plotpdf savefigure

if size(ebsd,2) > 10000 || check_option(varargin,'points')
  points = get_option(varargin,'points',20000);
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(sum(size(ebsd,2))),' given orientations']);
  ebsd = subsample(ebsd,points);
end

plot(getgrid(ebsd),varargin{:});
