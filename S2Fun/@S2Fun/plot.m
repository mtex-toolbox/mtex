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

if isa(sF.CS,'crystalSymmetry')
  tooltipFormat = sF.CS.lattice.hklForm;
else
  tooltipFormat = 'xyz';
end
tooltipFormat = get_flag(varargin,{'hkl','uvw','xyz','UVTW','hkil'},tooltipFormat);

%
if sF.antipodal, varargin = [varargin,'antipodal']; end

S2Proj = makeSphericalProjection(varargin{:},sF.how2plot);

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
  h = gobjects(length(S2Proj),length(sF));
  ax = h;
  ulLabel = {};
  for j = 1:length(sF)

    cR = [min(min(values{1}(:,j)),min(values{end}(:,j))),...
      max(max(values{1}(:,j)),max(values{end}(:,j)))];
    
    for ul = 1:length(values)
    
      if j + ul > 2, mtexFig.nextAxis; end
      
      if length(S2Proj) == 2 && ul == 1
        ulLabel = {'TR','upper'};
      elseif length(S2Proj) == 2 
        ulLabel = {'TR','lower'};
      end
      
      % plot the function values
      [h(ul,j),ax(ul,j)] = plot(plotNodes{ul},values{ul}(:,j),ulLabel{:},...
        'pcolor','hold','colorRange',cR,S2Proj(ul),varargin{:});
      
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
   
    switch tooltipFormat
      case "xyz"
        txt = {...
          ['value: ' xnum2str(value,'fixedWidth',5) ];...
          ['x    : ' xnum2str(r_local.x,'precision',3)];...
          ['y    : ' xnum2str(r_local.y,'precision',3)];...
          ['z    : ' xnum2str(r_local.z,'precision',3)]};
      case {"uvw", "hkl","UVTW","hkil"}
        r_local = Miller(r_local,sF.CS);
        r_local.dispStyle = tooltipFormat;
        
        txt = [xnum2str(value) ' at ' char(round(r_local))];
    end
  
  end

end