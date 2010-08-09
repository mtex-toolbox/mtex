function varargout = get(obj,vname,varargin)
% extract data from a Pole Figure object
%
%% Syntax
%  d = get(ebsd,'orientations')  % individuel orientations
%  s = get(ebsd,'CS')            % crystal symmetry
%  x = get(ebsd,'x')             % x coordinates
%  y = get(ebsd,'y')             % y coordinates
%  p = get(ebsd,'property')      % properties asociated with the orientations
%  m = get(ebsd,'mad')           % MAD
% 
%% Input
%  ebsd - @EBSD
%
%% Options
%  phase - phase to consider
%
%% Output
%  d - @orientation
%  s - @symmetry
%  x,y,p,m - double
%
%% See also
% EBSD/set



if nargin == 1
  vnames = get_obj_fields(obj(1),'options');
  if nargout, varargout{1} = vnames; else disp(vnames), end
else

varargout{1} = [];
switch vname
  case {'SS','CS'}
     varargout = cellfun(@(x) get(x,(vname)) ,{obj.orientations},'uniformoutput',false);
  case {'comment','options'}    
    varargout = {obj.(vname)};    
  case {'data','orientations','orientation'}   
    
    % extract phases
    phase = [obj.phase];
    phases = unique(phase);
    
    if check_option(varargin,'phase')
      
      ind = phase == get_option(varargin,'phase');
      
    elseif numel(phases) > 1 && check_option(varargin,'CheckPhase')
      
      warning('MTEX:MultiplePhases','This operatorion is only permitted for a single phase! I''m going to process only the first phase.');
      ind = phase == phases(1);
      
    else
      
      ind = true(numel(obj),1);
      
    end
    
    [d dim]= max(size(obj(1).orientations));
    if dim==1
      varargout{1} = vertcat(obj(ind).orientations);
    else
      varargout{1} = horzcat(obj(ind).orientations);
    end
    varargout{2} = ind;  
  case fields(obj)
    varargout{1} = vertcat(obj.(vname));    
  case {'quaternions','quaternion'}
    varargout{1} = quaternion();
    for i = 1:length(obj)
      varargout{1} = [varargout{1};reshape(quaternion(obj(i).orientations),[],1)]; 
    end
  case 'length'
    varargout{1} = zeros(1,length(obj));
    for i = 1:length(obj)
      varargout{1}(i) = sum(numel(obj(i).orientations));
    end
  case 'x'
    for i = 1:length(obj)
      varargout{1} = [varargout{1};obj(i).xy(:,1)]; 
    end
  case 'y'
    for i = 1:length(obj)
      varargout{1} = [varargout{1};obj(i).xy(:,2)]; 
    end
  case fields(obj(1).options)
     options = [obj.options];
     varargout{1} = vertcat(options.(vname));    
%     for i = 1:length(obj)
%       varargout{1} = [varargout{1};reshape(obj(i).options.(vname),[],1)]; %#ok<AGROW>
%     end
  otherwise
    error(['There is no ''' vname ''' property in the ''EBSD'' object'])
end

end
