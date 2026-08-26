function plot(pf,varargin)
% plot pole figure
%
% Syntax
%   plot(pf)
%   plot(pf{1})         % plot only the first pole figure
%   plot(pf,'contour')  % contour plot
%   plot(pf,'contourf') % filled contour plot
%   plot(pf,'smooth')   % smooth plot
%   plot(pf,'minmax')   % show min and max
%   mtexColorbar        % show colorbar
%
% Input
%  pf - @PoleFigure
%

%
% See also
% vector3d/plot saveFigure Plotting Annotations ColorMaps PlotTypes
% SphericalProjections 

[mtexFig,isNew] = newMtexFigure(varargin{:});

% every plot command below lays the figure out and the next throws that
% away - hold it until the figure is finished, see layoutHold
layoutRelease = layoutHold(mtexFig); %#ok<NASGU>


if nargin > 1 && isnumeric(varargin{1})
  data = mat2cell(varargin{1}(:),cellfun('prodofsize',pf.allI));
else
  data = pf.allI;
end

gList = gobjects(0,1);
for i = 1:length(pf.allH)
  
  if isempty(pf.allI{i}), continue; end
  if i>1, mtexFig.nextAxis; end
  
  [g,cax] = pf.allR{i}.plot(data{i},...
    'dynamicMarkerSize','parent',mtexFig.gca,varargin{:});
  mtexTitle(mtexFig.gca,char(pf.allH{i},'LaTeX'));

  set(cax,'tag','pdf');
  setAllAppdata(cax,'SS',pf.SS,'h',pf.allH{i});

  gList = [gList;g(:)]; %#ok<AGROW>  

end

% unify dynamic marker size
gList = findall(gList,'tag','dynamicMarkerSize');
try [gList.UserData] = deal(min([gList.UserData])); end %#ok<TRYNC>

if isNew || check_option(varargin,'figSize')
  % the figure is finished - lay it out, once
  clear layoutRelease

  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

if isNew % finalize plot
  set(gcf,'Name',['Pole Figures of Specimen ',inputname(1)]);
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  if check_option(varargin,'3d'), fcw(gcf,'-link'); end
end
