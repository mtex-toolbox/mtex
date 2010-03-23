function plotodf(odf,varargin)
% plot odf
%
% Plots the ODF as various sections which can be controled by options. 
%
%% Input
%  odf - @ODF
%
%% Options
%  SECTIONS   - number of plots
%  RESOLUTION - resolution of each plot
%  CENTER     - for radially symmetric plot
%  AXES       - for radially symmetric plot
%
%% Flags
%  SIGMA (default)
%  ALPHA
%  GAMMA      
%  PHI1
%  PHI2
%  RADIALLY
%  AXISANGLE
%
%% See also
% S2Grid/plot savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

%% -------- one - dimensional plot ---------------------------------------
if check_option(varargin,'RADIALLY')   
  plotodf1d(odf,varargin{:});
  return
end  

%% two dimensional sections

% make new plot
newMTEXplot;

% generate grids
[S3G,S2G,sec] = SO3Grid('plot',odf(1).CS,odf(1).SS,varargin{:});

Z = eval(odf,orientation(S3G),varargin{:});


%% ------------------------- plot -----------------------------------------
sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','axisangle'},'sigma');
[symbol,labelx,labely] = sectionLabels(sectype);

fprintf(['\nPlotting ODF as ',sectype,' sections, range: ',...
  xnum2str(min(sec)/degree),mtexdegchar,' - ',xnum2str(max(sec)/degree),mtexdegchar,'\n']);

if check_option(varargin,'contour3s')
  
	alphabeta = get(S3G,'alphabeta');
  clear S3G;
  switch lower(sectype)
    case {'phi_1','alpha','phi1'}
      alphabeta = alphabeta(:,[3 2]);
    case {'phi_2','gamma','phi2'}
      alphabeta = alphabeta(:,[1 2]);
    case 'sigma'
      alphabeta = alphabeta(:,[2 1]);
  end
    
  lim = [min(alphabeta) max(alphabeta)];
  xlim = linspace(lim(1),lim(3),size(Z,1));
  ylim = linspace(lim(2),lim(4),size(Z,2));
  zlim = sec;    
 
  v = get_option(varargin,'contour3s',10,'double');
  
  contour3s(xlim./degree,ylim./degree,zlim./degree,Z,v,varargin{:})
 
  xlabel(labely);  ylabel(labelx);  zlabel(symbol);
    
else
  
  clear S3G;
  multiplot(@(i) S2G,...
    @(i) Z(:,:,i),...
    length(sec),...
    'DISP',@(i,Z) [' ',symbol(2:end),' = ',xnum2str(sec(i)/degree),mtexdegchar,' ',...
    ' Max: ',xnum2str(max(Z(:))),...
    ' Min: ',xnum2str(min(Z(:)))],...
    'ANOTATION',@(i) [int2str(sec(i)*180/pi),'^\circ'],...
    'MINMAX','SMOOTH','TIGHT',...
    'xlabel',labelx,'ylabel',labely,...
    'colorrange','equal','margin',0,varargin{:}); %#ok<*EVLC>

end

name = inputname(1);
if isempty(name), name = odf(1).comment;end
set(gcf,'Name',['ODF "',name,'"']);
setappdata(gcf,'sections',sec);
setappdata(gcf,'SectionType',sectype);
setappdata(gcf,'CS',odf(1).CS);
setappdata(gcf,'SS',odf(1).SS);
set(gcf,'tag','odf')
