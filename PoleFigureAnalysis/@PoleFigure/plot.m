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
    {{'CS',pf.CS},{'SS',pf.SS},{'h',pf.allH}});
end

field = lower(get_option(varargin,'colorcoding',[]));

% TODO !!!
if isProp(pf,field)
  pfunc = @(i) pf({i}).(field);
else
  pfunc = @(i) pf.allI{i};
end

if check_option(varargin,{'contourf','contour','smooth'}) && ...
    (size(pfunc(1),1) == 1 || size(pfunc(1),2) == 1)
  
  warning('%s%s\n%s','Unexpected option: ',varargin{find_option(varargin,{'contourf','contour','smooth'})},...
    ' Discrete pole figure data should only plotted as points!'); %#ok<WNTAG>
  
end

vdisp(' ',varargin{:});
vdisp('Plotting pole figures:',varargin{:})

multiplot(ax{:},pf.numPF,@(i) pf.allR{i},pfunc,'TR',@(i) pf.allH{i},...
  'dynamicMarkerSize',...
  varargin{:});

if isempty(ax)
  setappdata(gcf,'h',pf.allH);
  setappdata(gcf,'SS',pf.SS);
  setappdata(gcf,'CS',pf.CS);
  set(gcf,'Name',['Pole Figures of Specimen ',inputname(1)]);
  set(gcf,'Tag','pdf');
end
