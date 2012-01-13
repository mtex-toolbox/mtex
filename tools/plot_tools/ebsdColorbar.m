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
% orientation2color

% input check
if nargin >= 1 && isa(varargin{1},'symmetry')  
  cs = varargin{1};
  varargin = varargin(2:end);
  cc = get_option(varargin,'colorcoding','ipdf');
  r = get_option(varargin,'r',xvector);
else
  cs = getappdata(gcf,'CS');
  if ~iscell(cs), cs = {cs};end
  
  r = getappdata(gcf,'r');
  o = getappdata(gcf,'options');
  varargin = {o{:},varargin{:}};
  cc = get_option(varargin,'colorcoding',getappdata(gcf,'colorcoding'));  
  ccenter = getappdata(gcf,'colorcenter');
  if ~isempty(ccenter), varargin = {'colorcenter',ccenter,varargin{:}}; end
    
  if isappdata(gcf,'rotate')
    varargin = set_default_option(varargin,[],'rotate',getappdata(gcf,'rotate'));
  end
  
  
  for i = 1:length(cs)
    ebsdColorbar(cs{i},varargin{:},...
      'r',r,'colorcoding',cc);
    set(gcf,'Name',[ '[' cc '] Colorcoding for phase ',get(cs{i},'mineral')]);
  end
  return
end

figure
newMTEXplot;

% get default options
varargin = set_default_option(varargin,...
  get_mtex_option('default_plot_options'));

if any(strcmp(cc,{'ipdf','hkl'}))  
  % hkl is antipodal
  if strcmp(cc,'hkl'),  varargin = {'antipodal',varargin{:}}; end  
  
  [maxtheta,maxrho,minrho,v] = getFundamentalRegionPF(cs,varargin{:});
  
  %maxrho = maxrho-minrho+eps;
  %minrho = 0; % rotate like canvas %TODO:flipud!
  h = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,'RESTRICT2MINMAX','resolution',1*degree,varargin{:});

  if strcmp(cc,'ipdf')
    d = ipdf2rgb(h,cs,varargin{:});
  elseif strcmp(cc,'hkl')    
    d = ipdf2hkl(h,cs,varargin{:});
  end
  
  d = reshape(d,[size(h),3]);
  
  multiplot(@(i) h,@(i) d,1,'rgb',varargin{:});
  
  type = 'ipdf';
else
  [S3G,S2G,sec] = SO3Grid('plot',cs,symmetry,varargin{:});
  
  [s1,s2,s3] = size(S3G);
  
  d = reshape(orientation2color(S3G,cc,varargin{:}),[s1,s2,s3,3]);
  
	sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma'},'sigma');
    [symbol,labelx,labely] = sectionLabels(sectype);   
    
  fprintf(['\nplot ',sectype,' sections, range: ',...
    xnum2str(min(sec)/degree),mtexdegchar,' - ',xnum2str(max(sec)/degree),mtexdegchar,'\n']);

  multiplot(@(i) S2G,...
    @(i) reshape(d(:,:,i,:), [size(d(:,:,i,:),1),size(d(:,:,i,:),2),3]),...
    length(sec),'rgb',...
    'ANOTATION',@(i) [symbol,'=',int2str(sec(i)*180/pi),'^\circ'],...  'MINMAX','SMOOTH','TIGHT',...
       'xlabel',labelx,'ylabel',labely,...  
       'equal','margin',0,varargin{:}); %#ok<*EVLC>
     
     
  setappdata(gcf,'sections',sec);
  setappdata(gcf,'SectionType',sectype);  
	type = 'odf';
end

set(gcf,'tag',type);
setappdata(gcf,'colorcoding',cc);
setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
setappdata(gcf,'CS',cs);
setappdata(gcf,'SS',symmetry);
setappdata(gcf,'r',r);
setappdata(gcf,'options',extract_option(varargin,'antipodal'));

%% annotate crystal directions
if any(strcmp(cc,{'ipdf','hkl'}))
  annotate(v,'MarkerFaceColor','k','labeled','all');
end
set(gcf,'renderer','opengl');

