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
  colorcoding = get_option(varargin,'colorcoding',@(h) ipdf2rgb(h,cs,varargin{:}));  
  r = get_option(varargin,'r',xvector);
else
  cs = getappdata(gcf,'CS');
  r = getappdata(gcf,'r');
  o = getappdata(gcf,'options');
  varargin = {o{:},varargin{:}};
  colorcoding = getappdata(gcf,'colorcoding');  
  varargin = set_default_option(varargin,[],'rotate',getappdata(gcf,'rotate'));
  
  for i = 1:length(cs)
    ebsdColorbar(cs{i},varargin{:},'colorcoding',@(h) colorcoding(h,i),...
      'r',r);
    set(gcf,'Name',['Colorcoding for phase ',get(cs{i},'mineral')]);
  end
  return
end

% get default options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

% S2 Grid
[maxtheta,maxrho,minrho,v] = getFundamentalRegionPF(cs,varargin{:});
h = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'resolution',1*degree,varargin{:});

d = reshape(colorcoding(h),[GridSize(h),3]);

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




