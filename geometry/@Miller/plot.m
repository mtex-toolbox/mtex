function plot(m,varargin)
% plot Miller indece
%
%% Input
%  m  - Miller
%
%% Options
%  ALL       - plot symmetrically equivalent directions
%  antipodal - include antipodal symmetry
%  labeled   - plot Miller indice as label
%  label     - plot user label
%
%% See also
% vector3d/plot

if check_option(varargin,{'smooth','contourf','contour'})
  
  o = extract_option(m,'antipodal');
    
  [maxtheta,maxrho,minrho] = getFundamentalRegionPF(m.CS,o{:},varargin{:});  
  out = S2Grid('PLOT','MAXTHETA',maxtheta,'MAXRHO',maxrho,'MINRHO',minrho,...
    'RESTRICT2MINMAX',o{:},varargin{:});

  x = symmetrise(m,'skipAntipodal');
  kde = kernelDensityEstimation(x,out,varargin{:});
  
  plot(out,'data',kde,varargin{:});
  return
end


if numel(m) > 20
  
  if check_option(varargin,{'ALL','symmetrised'})  
    m = symmetrise(m,'plot',varargin{:});
  end
  
  plot(m.vector3d,varargin{:});
  
  return
end

% store hold status
washold = ishold;
label = ensurecell(get_option(varargin,'label'),numel(m));

% get antipodal status
if washold && isappdata(gcf,'options') && check_option(getappdata(gcf,'options'),'antipodal')
  varargin = [varargin,'antipodal'];
end

for i = 1:numel(m)

  % all symmetrically equivalent?
  if check_option(varargin,{'ALL','symmetrised'})  
    mm = symmetrise(subsref(m,i),'plot',varargin{:});
  else
    mm = subsref(m,i);
  end

  options = {};
  if check_option(varargin,'labeled')
    % convert to cell
    s = num2cell(mm);
    options = {'label',s,'MarkerEdgeColor','w'};
  elseif ~isempty(label)
    varargin = set_option(varargin,'label',{label{i}});
  end
  
  % plot
  plot(S2Grid(mm),options{:},varargin{:});
  
  hold all
end

% revert old hold status
if ~washold, hold off;end

% set options
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
