function plotpdf(odf,h,varargin)
% plot pole figures
%
%% Syntax
% plotpdf(odf,[h1,..,hN],<options>)
% plotpdf(odf,{h1,..,hN},'superposition',{c1,..,cN},<options>)
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
%  COMPLETE - plot entire (hemi)--sphere
%
%% See also
% S2Grid/plot annotate savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

%% check input

% convert to cell
if ~iscell(h), h = vec2cell(h);end

% ensure crystal symmetry
try
  argin_check([h{:}],'Miller');
  for i = 1:length(h)
    h{i} = ensureCS(odf(1).CS,h(i));
  end
catch %#ok<CTCH>
  plotipdf(odf,h,varargin);
  return
end

% superposition coefficients
if check_option(varargin,'superposition')
  c = get_option(varargin,'superposition');
else
  c = num2cell(ones(size(h)));
end

% default options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));


%% make new plot
newMTEXplot;

%% plotting grid
[maxtheta,maxrho,minrho] = getFundamentalRegionPF(odf(1).SS,varargin{:});
r = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX',varargin{:});

%% plot
vdisp(' ',varargin{:});
vdisp('Plotting pole density functions:',varargin{:})
  
multiplot(numel(h),...
  r,@(i) ensureNonNeg(pdf(odf,h{i},r,varargin{:},'superposition',c{i})),...
  'smooth','TR',@(i) char(h{i},'LaTex'),varargin{:});

%% finalize plot
setappdata(gcf,'h',h);
setappdata(gcf,'CS',odf(1).CS);
setappdata(gcf,'SS',odf(1).SS);
set(gcf,'tag','pdf');
name = inputname(1);
if isempty(name), name = odf(1).comment;end
set(gcf,'Name',['Pole figures of "',name,'"']);
