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

S2Proj = makeSphericalProjection(varargin{:});

% generate a grid where the function will be plotted
plotNodes = ensurecell(S2Proj.makeGrid(varargin{:}));

% evaluate the function on the plotting grid
for i = 1:length(plotNodes)
  values{i} = reshape(sF.eval(plotNodes{i}),[],length(sF)); %#ok<AGROW>
end

if check_option(varargin,'ensureNonNeg')
  values = cellfun(@ensureNonNeg,values,'UniformOutput',false); 
end

if check_option(varargin,'rgb')
  
  [h,ax] = plot(plotNodes{1},values{1},'surf','hold',varargin{:});

else
  %h = []; ax = [];
  for j = 1:length(sF)
    for ul = 1:length(values)
    
      if j + ul > 2, mtexFig.nextAxis; end
    
      % plot the function values
      [h(ul,j),ax(ul,j)] = plot(plotNodes{ul},values{ul}(:,j),'pcolor','hold',S2Proj(ul),varargin{:});
      
    end
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
    
    %txt = [xnum2str(value) ' at (' xnum2str(r_local.theta/degree) ',' xnum2str(r_local.rho/degree) ')'];

    txt = {...
      ['value: ' xnum2str(value,'fixedWidth',5) ];...
      ['x    : ' xnum2str(r_local.x,'precision',3)];...
      ['y    : ' xnum2str(r_local.y,'precision',3)];...
      ['z    : ' xnum2str(r_local.z,'precision',3)]};
  
  end

end
