function ebsdColorbar(varargin)
% plot a inverse pole figure reflecting EBSD data colorcoding
%
% Syntax
%   ebsdColorbar
%   ebsdColorbar(cs)
%
% Input
%  cs - @symmetry
%
% Output
%
%
% See also
% orientation2color

% ---------------- input check ---------------------------
if nargin >= 1 && isa(varargin{1},'symmetry')
  
  cs = varargin{1};
  varargin = varargin(2:end);
  cc = get_option(varargin,'colorcoding','ipdfHSV');
  r = get_option(varargin,'r',xvector);
  
  varargin = set_default_option(varargin,{'r',r});
  
else
  
  cs = getappdata(gcf,'CS');
  if ~iscell(cs), cs = {cs};end
  CCOptions = getappdata(gcf,'CCOptions');
  
  for i = 1:numel(cs)
    if isa(cs{i},'symmetry')
            
      cc = getappdata(gcf,'colorcoding');
      options = ensurecell(CCOptions{i});
      ebsdColorbar(cs{i},options{:},varargin{:},'colorcoding',cc);

      set(gcf,'Name',[ '[' cc '] Colorcoding for phase ',cs{i}.mineral]);
    end
  end
  return
end


% ------------------- plot colorbars ---------------------

figure
newMTEXplot;

if strncmp(cc,'ipdf',3) && ~check_option(varargin,'orientationSpace')
  
  type = 'ipdf';
  ipdfColorbar(cs,cc,varargin{:});
  
elseif strcmp(cc,'patala')
    
  type = 'patala';
  patalaColorbar(cs,cc,varargin{:});
  
% Colorize orientation space
else
  
  odfColorbar(cs,cc,varargin{:});
  type = 'odf';
  
end


% ----------------- finalize plot ---------------------------

set(gcf,'tag',type);
setappdata(gcf,'colorcoding',cc);
setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
setappdata(gcf,'CS',cs);
setappdata(gcf,'SS',symmetry);
setappdata(gcf,'r',r);
setappdata(gcf,'options',extract_option(varargin,'antipodal'));

end


% -------------------- colorbar for ipdf color coding  ------------
function ipdfColorbar(cs,cc,varargin)

% hkl is antipodal
if strcmpi(cc,'ipdfHKL'),  varargin = [{'antipodal'},varargin]; end

sR = fundamentalSector(cs,varargin{:});

h = plotS2Grid(sR,'resolution',1*degree,varargin{:});
r = get_option(varargin,'r');

d = orientation2color(h,cc,cs,varargin{:});

if numel(d) == 3*length(h)
  d = reshape(d,[size(h),3]);
  surf(h,d,'TL',r,varargin{:});
else
  contourf(h,d,'TL',r,varargin{:});
end

%title(['r = ' char(r,'tex')])
  
% annotate crystal directions
set(gcf,'tag','ipdf')
setappdata(gcf,'CS',cs);
h = Miller(sR.vertices,cs);
h.dispStyle = 'uvw';
annotate(round(h),'MarkerFaceColor','k','labeled','symmetrised');

end

% ------------------- colorbar for Euler color coding ------------
function odfColorbar(cs,cc,varargin)

S3Goptions = delete_option(varargin,'axisAngle');
[S3G,S2G,sec] = regularSO3Grid(cs,symmetry,varargin{:});

[s1,s2,s3] = size(S3G);

d = orientation2color(S3G,cc,varargin{:});
if numel(d) == length(S3G)
  rgb = 1;
  varargin = [{'smooth'},varargin];
else
  rgb = 3;
  varargin = [{'surf'},varargin];
end
d = reshape(d,[s1,s2,s3,rgb]);

sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma'},'phi2');
[symbol,labelx,labely] = sectionLabels(sectype);

if strcmp(sectype,'sigma')
  varargin = [{'innerPlotSpacing',10},varargin];
else  
  varargin = [{'projection','plain',...
    'xAxisDirection','east','zAxisDirection','intoPlane',...
    'innerPlotSpacing',35,'outerPlotSpacing',35},varargin];
end

fprintf(['\nplot ',sectype,' sections, range: ',...
  xnum2str(min(sec)/degree),mtexdegchar,' - ',xnum2str(max(sec)/degree),mtexdegchar,'\n']);

multiplot(length(sec),@(i) S2G,...
  @(i) reshape(d(:,:,i,:), [size(d(:,:,i,:),1),size(d(:,:,i,:),2),rgb]),...
  'TR',@(i) [int2str(sec(i)*180/pi),'^\circ'],...
  'xlabel',labelx,'ylabel',labely,varargin{:}); %#ok<*EVLC>

setappdata(gcf,'sections',sec);
setappdata(gcf,'SectionType',sectype);

end
