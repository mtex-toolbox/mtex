function plotFundamentalRegion(CS,varargin)
% plots fundamental in odf-space
%
%% Input
%  CS - @symmetry
%
%% Options
%  zone -  1..n, plot only a specific fundamental region 
%  center - @ plot
%
%% See also
% odf/plotodf orientation/plotodf

sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','axisangle','omega'},'sigma');

qcenter = quaternion(get_option(varargin,'center',idquaternion))*CS;

% define a plotting grid
[S3G,S2,sec] = SO3Grid('plot',CS,symmetry,varargin{:});

% specifiy which fundamental zone is at an orientation
[d,zone] = max(abs(dot_outer(quaternion(S3G),qcenter)),[],2);
zone = reshape(zone,size(S3G));

if check_option(varargin,'zone')
  z = get_option(varargin,'zone');
  uzone = unique(zone);
  zone = double(zone==uzone(z));
end

% plot all fundamental zones around center together
multiplot(@(i) S2,@(i) zone(:,:,i),numel(sec),...
  'ANOTATION',@(i) [int2str(sec(i)*180/pi),'^\circ'],...
  'SMOOTH','TIGHT',...
   'colorrange','equal','margin',0,...
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

