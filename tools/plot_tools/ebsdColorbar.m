function ebsdColorbar(varargin)
% plot a inverse pole figure reflecting EBSD data colorcoding
%
%% Syntax
%  ebsdColorbar
%  ebsdColorbar(cs)
%
%% Input
%  cs - @symmetry
%
%% Output
%
%
%% See also
%

% input check
if nargin >= 1 && isa(varargin{1},'symmetry')  
  cs = varargin{1};
  varargin = varargin(2:end);
  colorcoding = get_option(varargin,'colorcoding',@(h) orientation2color(h,'ipdf',varargin{:}));  
  cc = get_option(varargin,'colorcode','ipdf');
  r = get_option(varargin,'r',xvector);
else
  cs = getappdata(gcf,'CS');
  r = getappdata(gcf,'r');
  o = getappdata(gcf,'options');
  varargin = {o{:},varargin{:}};
  colorcoding = getappdata(gcf,'colorcoding');  
  cc = getappdata(gcf,'colorcode');
  varargin = set_default_option(varargin,[],'rotate',getappdata(gcf,'rotate'));
  
  for i = 1:length(cs)
    ebsdColorbar(cs{i},varargin{:},'colorcoding',@(h) colorcoding(h,i),...
      'r',r,'colorcode',cc);
    set(gcf,'Name',['Colorcoding for phase ',get(cs{i},'mineral')]);
  end
  return
end

% get default options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% S2 Grid
[maxtheta,maxrho,minrho,v] = getFundamentalRegionPF(cs,varargin{:});

if strcmp(cc,'ipdf') && r == xvector 
   h = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'resolution',1*degree,varargin{:});
else
   h =  S2Grid('resolution',1.5*degree,'Plot');
end

 vh = vector3d(h);
 grid = SO3Grid(axis2quat(cross(vh,r),angle(vh,r)),cs);
 
 d = reshape(orientation2color(grid,cc),[GridSize(h),3]);
 

figure
multiplot(@(i) h,@(i) d,1,'rgb',varargin{:});
set(gcf,'tag','ipdf');
setappdata(gcf,'CS',cs);
setappdata(gcf,'SS',symmetry);
setappdata(gcf,'r',r);
setappdata(gcf,'options',extract_option(varargin,'antipodal'));

%% annotate crystal directions

annotate(v,'MarkerFaceColor','k','labeled','all');
set(gcf,'renderer','opengl');




