function annotate(varargin)
% plots to all axes of the current figure
%
% Syntax
%   annotate([xvector,yvector,zvector])
%   annotate(Miller(1,1,1,cs),'all')
%
% Description
% The function *annotate* plots annotations, e.g. specimen or crystal
% directions to all subfigures of the current figure. You can pass to
% *annotate* all the options you would normaly would like to pass to the
% ordinary plot command.
%
% See also
% Miller/plot vector3d/plot

% preprocessing

% no arguments -> quit
if nargin == 0 || isempty(varargin{1}), return; end

% remember hold state
washold = ishold;
hold all;

% get default style
defaultAnnotationStyle = {'marker','s','MarkerEdgeColor','w',...
  'MarkerFaceColor','k'};

% extract object to annotate
obj = varargin{1};
varargin(1) = [];

% extract crystal and specimen symmetry if present
ss = getappdata(gcf,'SS');
cs = getappdata(gcf,'CS');

% plotting
switch get(gcf,'tag')
      
  case 'pdf' % pole figure annotations
    if isa(obj,'quaternion')
      
      % force right crystal and specimen symmetry
      plotPDF(orientation(obj,cs,ss),[],defaultAnnotationStyle{:},varargin{:});
      
    elseif isa(obj,'vector3d')
  
      multiplot([],obj,defaultAnnotationStyle{:},varargin{:});
        
    else
      error('Only orientations and specimen directions can be anotated to pole figure plots');
    end
    
    
    case {'ipdf','hkl','AxisDistribution'} % inverse pole figure plot
      
      if isa(obj,'quaternion')
        
        plotIPDF(orientation(obj,cs,ss),[],defaultAnnotationStyle{:},varargin{:});
        
      elseif isa(obj,'Miller')
        
        obj = cs.ensureCS(obj);
        multiplot([],obj,'symmetrised',defaultAnnotationStyle{:},varargin{:});
        
      else        
        error('Only orientations and Miller indece can be anotated to inverse pole figure plots');
      end
      

  case 'ebsd_scatter' % EBSD 3d scatter plot      
      
    if isa(obj,'quaternion')
      plot(orientation(obj,cs,ss),'center',getappdata(gca,'center'),varargin{:});
    else
      error('Only orientations can be anotated to EBSD scatter plots');
    end
      

  case 'tensor' % Tensor plot    
    
    if isa(obj,'vector3d')
      
      multiplot([],obj,defaultAnnotationStyle{:},varargin{:});
      
    else
      error('Only crystal and specimen directions can be anotated to tensor plots');
    end
    
    
  case 'odf' % ODF sections plot
      
    if strcmpi(getappdata(gcf,'SectionType'),'omega')
      varargin = set_default_option(varargin,{getappdata(gcf,'h')});
    end
    
    % compute projection to ODF sections
    S2G = project2ODFsection(orientation(obj,cs,ss),...
      getappdata(gcf,'SectionType'),getappdata(gcf,'sections'),varargin{:});
    
    if isa(obj,'quaternion')
      multiplot([],@(i) S2G{i},defaultAnnotationStyle{:},varargin{:});
    else
      error('Only orientations can be anotated to ODF section plots');
    end
    
end

% postprocess axes
if ~washold, hold off;end
