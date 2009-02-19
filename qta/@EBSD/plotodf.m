function plotodf(ebsd,varargin)
% Plots the EBSD data at various sections which can be controled by options. 
%
%% Input
%  ebsd - @EBSD
%
%% Options
%  SECTIONS   - number of plots
%
%% Flags
%  SIGMA (default)
%  ALPHA
%  GAMMA      
%  PHI1
%  PHI2
%
%% See also
% S2Grid/plot savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

% subsample to reduce size
if sum(sampleSize(ebsd)) > 2000 || check_option(varargin,'points')
  points = get_option(varargin,'points',2000);
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(sum(sampleSize(ebsd))),' given orientations']);
  ebsd = subsample(ebsd,points);
end

% reuse plot
if ishold && isappdata(gcf,'sections') && ...
    getappdata(gcf,'CS') == ebsd(1).CS && getappdata(gcf,'SS') == ebsd(1).SS
  
  sectype = getappdata(gcf,'SectionType');
  sec = getappdata(gcf,'sections');
  
else
  
  rmallappdata(gcf);
  hold off;
  sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma'},'sigma');

  % get fundamental plotting region
  [max_rho,max_theta,max_sec] = getFundamentalRegion(ebsd(1).CS,ebsd(1).SS,varargin{:});

  if any(strcmp(sectype,{'alpha','phi1'}))
    dummy = max_sec; max_sec = max_rho; max_rho = dummy;
  end
  
  nsec = get_option(varargin,'SECTIONS',round(max_sec/degree/5));
  sec = linspace(0,max_sec,nsec+1); sec(end) = [];
  sec = get_option(varargin,sectype,sec,'double');
  varargin = {varargin{:},'maxrho',max_rho,'maxtheta',max_theta};
end

[symbol,labelx,labely] = sectionLabels(sectype);

%% generate plots
S2G = project2ODFsection([ebsd.orientations],sectype,sec,varargin{:});
S2G = set(S2G,'res',get(S2G,'resolution'));

%% ------------------------- plot -----------------------------------------
multiplot(@(i) S2G(i),@(i) [],length(sec),...
  'ANOTATION',@(i) [symbol,'=',int2str(sec(i)*180/pi),'^\circ'],...
  'xlabel',labelx,'ylabel',labely,...
  'margin',0,'dynamicMarkerSize',...
  varargin{:});

setappdata(gcf,'sections',sec);
setappdata(gcf,'SectionType',sectype);
setappdata(gcf,'CS',ebsd(1).CS);
setappdata(gcf,'SS',ebsd(1).SS);
