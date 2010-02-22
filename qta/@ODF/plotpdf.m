function plotpdf(odf,h,varargin)
% plot pole figures
%
%% Syntax
% plotpdf(odf,[h1,..,hN],<options>)
% plotpdf(odf,[h1,..,hN],'superposition',[c1,..,cN],<options>)
%
%% Input
%  odf - @ODF
%  h   - @Miller crystallographic directions
%  c   - structure coefficients
%
%% Options
%  RESOLUTION    - resolution of the plots 
%  SUPERPOSITION - plot superposed pole figures
%
%% Flags
%  antipodal    - include [[AxialDirectional.html,antipodal symmetry]]
%  COMPLETE - plot entire (hemi)-sphere
%
%% See also
% S2Grid/plot annotate savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

%% check input
if iscell(h), h = [h{:}];end
argin_check(h,'Miller');
h = set(h,'CS',odf(1).CS);

% default options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));


%% make new plot
newMTEXplot;

%% plotting grid
if check_option(varargin,'3d')
  r = S2Grid('PLOT',varargin{:});
else
  [maxtheta,maxrho,minrho] = getFundamentalRegionPF(odf(1).SS,varargin{:});
  r = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX',varargin{:});
end


%% plot
vdisp(' ',varargin{:});
vdisp('Plotting pole density functions:',varargin{:})
if check_option(varargin,'superposition')
  multiplot(@(i) r,@(i) max(0,pdf(odf,h,r,varargin{:})),1,...
    'DISP',@(i,Z) [' h=',char(h),...
    ' Max: ',num2str(max(Z(:))),...
    ' Min: ',num2str(min(Z(:)))],...
    'ANOTATION',@(i) h,...
    'MINMAX','SMOOTH',...
    'appdata',@(i) {{'h',h}},...
    varargin{:});
else
  multiplot(@(i) r,@(i) pos(pdf(odf,h(i),r,varargin{:})),length(h),...
    'DISP',@(i,Z) [' PDF h=',char(h(i)),...
    ' Max: ',num2str(max(Z(:))),...
    ' Min: ',num2str(min(Z(:)))],...
    'ANOTATION',@(i) h(i),...
    'MINMAX','SMOOTH',...
    'appdata',@(i) {{'h',h(i)}},...
    varargin{:});  
end

setappdata(gcf,'h',h);
setappdata(gcf,'CS',odf(1).CS);
setappdata(gcf,'SS',odf(1).SS);
set(gcf,'tag','pdf');
name = inputname(1);
if isempty(name), name = odf(1).comment;end
set(gcf,'Name',['Pole figures of "',name,'"']);

function d = pos(d)

if min(d(:)) > -1e-5, d = max(d,0);end
