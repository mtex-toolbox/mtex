function plot(pf,varargin)
% plot pole figure
%
% plots the Diffraction intensities as distinct colord dots on the sphere
%
%% Input
%  pf - @PoleFigure
%
%% Options
%  BACKGROUND   - plot background data
%
%% See also
% S2Grid/plot savefigure plot_index Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

%% new plot
newMTEXplot('ensureTag','pdf','ensureAppdata',...
    {{'CS',pf(1).CS},{'SS',pf(1).SS},{'h',get(pf,'h')}});

field = lower(get_option(varargin,'colorcoding',[]));
if isfield(pf(1).options,field)
  pfunc = @(i) pf(i).options.(field);
else
  pfunc = @(i) pf(i).data;
end

if check_option(varargin,{'contourf','contour','smooth'}) && ...
    (size(pfunc(1),1) == 1 || size(pfunc(1),2) == 1)
  
  warning('%s%s\n%s','Unexpected option: ',varargin{find_option(varargin,{'contourf','contour','smooth'})},...
    ' Discrete pole figure data should only plotted as points!'); %#ok<WNTAG>
  
end

vdisp(' ',varargin{:});
vdisp('Plotting pole figures:',varargin{:})
multiplot(@(i) pf(i).r,pfunc,length(pf),...
  'DISP',@(i,Z) [' h=',char(pf(i).h),' Max: ',num2str(max(Z(:))),...
  ' Min: ',num2str(min(Z(:)))],...
  'ANOTATION',@(i) pf(i).h,...
  'MINMAX','dynamicMarkerSize',...
  'appdata',@(i) {{'h',pf(i).h}},...
  varargin{:});

setappdata(gcf,'h',get(pf,'h'));
setappdata(gcf,'SS',pf(1).CS);
setappdata(gcf,'CS',pf(1).SS);
set(gcf,'Name',['Pole Figures of Specimen ',inputname(1)]);
set(gcf,'Tag','pdf');
