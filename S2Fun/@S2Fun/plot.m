function h = plot(sF,varargin)
%
% Syntax
%
% Input
%
% Output
%
% Options
%
% See also
%

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% generate a grid where the function will be plotted
plotNodes = plotS2Grid(varargin{:});

% evaluate the function on the plotting grid
values = sF.eval(plotNodes);

for j = 1:length(sF)

  if j > 1, mtexFig.nextAxis; end
  
  % plot the function values
  h(j) = plot(plotNodes,values(:,j),'parent',mtexFig.gca,'contourf',varargin{:}); %#ok<AGROW>
  
end

if isNew % finalize plot
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  if check_option(varargin,'3d'), fcw(gcf,'-link'); end
end

% remove output if not required
if nargout == 0, clear h; end

  function txt = tooltip(varargin)
    
    [r_local,v] = getDataCursorPos(mtexFig);
    %v = sF.eval(r_local);
    
    txt = [xnum2str(v) ' at (' int2str(r_local.theta/degree) ',' int2str(r_local.rho/degree) ')'];
  
  end

end
