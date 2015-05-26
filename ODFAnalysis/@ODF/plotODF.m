function plotODF(odf,varargin)
% plot odf
%
% Plots the ODF as various sections which can be controled by options.
%
% Input
%  odf - @ODF
%
% Options
%  sections   - number of sections
%  resolution - resolution of each plot
%
% Flags
%  phi2  - sections along phi2 Bunge angle (default)
%  phi1  - sections along phi1 Bunge angle
%  sigma - sections along phi1 - phi2
%  alpha - sections along alpha Matthies angle
%  gamma - sections along gamma Matthies angle
%  omega - sections along crystal directions @Miller
%
%  contour3, surf3, slice3 - 3d volume plot
%
% See also
% S2Grid/plot savefigure Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% generate grids
[S3G,S2G,sec] = plotSO3Grid(odf.CS,odf.SS,'resolution',2.5*degree,varargin{:});

Z = eval(odf,orientation(S3G),varargin{:});
clear S3G;

% ------------------------- plot -----------------------------------------
sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','omega','axisangle'},'phi2');
[symbol,labelx,labely] = sectionLabels(sectype);

if ~any(strcmpi(sectype,{'sigma','omega','axisangle'}))
  varargin = [{'projection','plain',...
    'xAxisDirection','east','zAxisDirection','intoPlane'},varargin];
end

fprintf(['\nPlotting ODF as ',sectype,' sections, range: ',...
  xnum2str(min(sec)/degree),mtexdegchar,' - ',xnum2str(max(sec)/degree),mtexdegchar,'\n']);

% make new plot
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

for i = 1:length(sec)
    
  if i>1, mtexFig.nextAxis; end
    
  S2G.plot(Z(:,:,i),'TR',[int2str(sec(i)*180/pi),'^\circ'],...
    'xlabel',labelx,'ylabel',labely,...
    'colorRange',[min(Z(:)),max(Z(:))],'smooth',...
    'parent',mtexFig.gca,'doNotDraw',varargin{:});
end
  
if isNew % finalize plot

  set(gcf,'Name',['ODF ' sectype '-sections "',inputname(1),'"']);
  setappdata(gcf,'sections',sec);
  setappdata(gcf,'SectionType',sectype);
  setappdata(gcf,'CS',odf.CS);
  setappdata(gcf,'SS',odf.SS);
  set(gcf,'tag','odf')

  if strcmpi(sectype,'omega') && ~isempty(find_type(varargin,'Miller'))
    h = varargin{find_type(varargin,'Miller')};
    setappdata(gcf,'h',h);
  end

  dcm = mtexFig.dataCursorMenu;
  uimenu(dcm, 'Label', 'Mark equivalent orientations', 'Callback', @markEquivalent);  
  
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  
end

% --------------- Tooltip function -------------------------------
function txt = tooltip(varargin)
  [ori,v] = currentOrientation;
  txt = [xnum2str(v) ' at ' char(ori,'nodegree')];
end

function markEquivalent(varargin)
  annotate(currentOrientation);
end


function [ori,value] = currentOrientation

  [pos,value,ax] = getDataCursorPos(mtexFig);

  iax = mtexFig.children == ax;

  switch getappdata(gcf,'SectionType')
    case 'phi1'
      euler1 = sec(iax);
      euler2 = pos.theta;
      euler3 = pos.rho;
      convention = 'Bunge';
    case 'phi2'
      euler3 = sec(iax);
      euler2 = pos.theta;
      euler1 = pos.rho;
      convention = 'Bunge';
    case 'alpha'
      euler3 = sec(iax);
      euler2 = pos.theta;
      euler1 = pos.rho;
      convention = 'Matthies';
    case 'sigma'
      euler1 = pos.rho;
      euler2 = pos.theta;
      euler3 = sec(iax) - pos.rho;
      convention = 'Matthies';
    otherwise
      error('unknown sectioning!')
  end

  ori = orientation('Euler',euler1,euler2,euler3,convention,odf.CS,odf.SS);

end

end

