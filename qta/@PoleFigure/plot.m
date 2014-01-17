function plot(pf,varargin)
% plot pole figure
%
% plots the diffraction intensities
%
% Input
%  pf - @PoleFigure
%
% Options
%  background   - plot background data
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo 

% new plot
[ax,pf,varargin] = getAxHandle(pf,varargin{:});
if isempty(ax),
  newMTEXplot('ensureTag','pdf','ensureAppdata',...
    {{'CS',pf(1).CS},{'SS',pf(1).SS},{'h',get(pf,'h')}});
end

field = lower(get_option(varargin,'colorcoding',[]));

% TODO !!!
%if isProp(pf(1),field)
%  pfunc = @(i) pf(i).(field);
%else
pfunc = @(i) pf(i).intensities;
%end

if check_option(varargin,{'contourf','contour','smooth'}) && ...
    (size(pfunc(1),1) == 1 || size(pfunc(1),2) == 1)
  
  warning('%s%s\n%s','Unexpected option: ',varargin{find_option(varargin,{'contourf','contour','smooth'})},...
    ' Discrete pole figure data should only plotted as points!'); %#ok<WNTAG>
  
end

vdisp(' ',varargin{:});
vdisp('Plotting pole figures:',varargin{:})

multiplot(ax{:},numel(pf),@(i) pf(i).r,pfunc,'TR',@(i) pf(i).h,...
  'dynamicMarkerSize',...
  varargin{:});

if isempty(ax)
  setappdata(gcf,'h',get(pf,'hCell'));
  setappdata(gcf,'SS',pf(1).SS);
  setappdata(gcf,'CS',pf(1).CS);
  set(gcf,'Name',['Pole Figures of Specimen ',inputname(1)]);
  set(gcf,'Tag','pdf');
end
