function plotFundamentalRegion(CS,varargin)
% plots fundamental in odf-space
%
% Input
%  CS - @symmetry
%
% Options
%  zone   -  1..n, plot only a specific fundamental region 
%  center - @quaternion
%
% See also
% odf/plotodf orientation/plotodf

sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','axisangle','omega'},'sigma');

qcenter = quaternion(get_option(varargin,'center',idquaternion))*CS;

% define a plotting grid
[S3G,S2,sec] = regularSO3Grid(CS,symmetry,varargin{:});

% specifiy which fundamental zone is at an orientation
[d,zone] = max(round(1000*abs(dot_outer(quaternion(S3G),qcenter))),[],2);

[dummy1,dummy2,zone] = unique(zone);
zone = reshape(zone,size(S3G));

if check_option(varargin,'zone')
  z = get_option(varargin,'zone');
  zone = double(zone==z);
end

% plot all fundamental zones around center together
multiplot(@(i) S2,@(i) zone(:,:,i),numel(sec),...
  'annotation',@(i) [int2str(sec(i)*180/pi),'^\circ'],...
  'tight','margin',0,'contourf',[-0.01,(1:numel(dummy1))-0.01],...
  varargin{:});

%setup some plot properties
set(gcf,'name',sectype)
setappdata(gcf,'sections',sec);
setappdata(gcf,'SectionType',sectype);
setappdata(gcf,'CS',CS);
setappdata(gcf,'SS',symmetry);
set(gcf,'tag','odf')

if strcmpi(sectype,'omega') && ~isempty(find_type(varargin,'Miller'))
  h = varargin{find_type(varargin,'Miller')};
  setappdata(gcf,'h',h);
end

