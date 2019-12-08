function [h,ax] = plot(sF,varargin)
% plot spherical Function
%
% Syntax
%   plot(sF)
%
% Flags
%  contourf - sF as filled contours
%  contour  - sF as contours
%
% See also
%   S2Fun/contour S2Fun/contourf S2Fun/pcolor S2Fun/plot3d
%

% create a new figure if needed
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

%
if sF.antipodal, varargin = [varargin,'antipodal']; end

% generate a grid where the function will be plotted
plotNodes = plotS2Grid(varargin{:});

% evaluate the function on the plotting grid
values = reshape(sF.eval(plotNodes),[],length(sF));

if check_option(varargin,'ensureNonNeg'), values = ensureNonNeg(values); end

if check_option(varargin,'rgb')
  
  [h,ax] = plot(plotNodes,values,'surf','hold',varargin{:});

else
  h = []; ax = [];
  for j = 1:length(sF)

    if j > 1, mtexFig.nextAxis; end
    
    % plot the function values
    [ch,cax] = plot(plotNodes,values(:,j),'pcolor','hold',varargin{:});
    h = [h,ch]; %#ok<*AGROW>
    ax = [ax,cax];
  
  end
end

if isNew % finalize plot
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
  if check_option(varargin,'3d'), fcw(gcf,'-link'); end
end

% remove output if not required
if nargout == 0, clear h; end

  function txt = tooltip(varargin)
    
    [r_local,~,value] = getDataCursorPos(mtexFig);
    %v = sF.eval(r_local);
    
    txt = [xnum2str(value) ' at (' int2str(r_local.theta/degree) ',' int2str(r_local.rho/degree) ')'];
  
  end

end
