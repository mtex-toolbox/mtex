function scatter(ebsd,varargin)
% plots ebsd data as scatter plot
%
%% Syntax
% scatter(ebsd,<options>)
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  AXISANGLE     - axis angle projection
%  RODRIGUEZ     - rodriguez parameterization
%  POINTS        - number of orientations to be plotted
%  CENTER        - orientation center
%
%% See also
% EBSD/plotpdf savefigure

%% prepare new figure
if newMTEXplot('ensureTag','ebsd_scatter',...
    'ensureAppdata',{{'CS',ebsd(1).CS},{'SS',ebsd(1).SS}});
  
  % reference orientation for fundamental region
  if ~check_option(varargin,'center')
    varargin = {varargin{:},'center',mean(ebsd)};
  end
    
else
  
  varargin = {'center',getappdata(gca,'center'),varargin{:}};
  
end


%% subsample to reduce size
if sum(sampleSize(ebsd)) > 2000 || check_option(varargin,'points')
  points = get_option(varargin,'points',2000);
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(sum(sampleSize(ebsd))),' given orientations']);
  ebsd = subsample(ebsd,points);
end

%% plot
plot(getgrid(ebsd),'scatter',varargin{:});

%% store appdata
setappdata(gcf,'CS',ebsd(1).CS);
setappdata(gcf,'SS',ebsd(1).SS);
setappdata(gca,'center',get_option(varargin,'center'));
set(gcf,'tag','ebsd_scatter');
