function varargout = get(obj,vname,varargin)
% get object variable

varargout{1} = [];
switch vname
  case 'CS'
    varargout = {obj.(vname)};
%    if check_option(varargin,'all')
%      varargout{1} = [obj.(vname)];
%    else
%      varargout{1} = obj(1).(vname);
%    end
  case {'comment','SS','options'}
    varargout{1} = obj(1).(vname);
  case fields(obj)
    varargout{1} = vertcat(obj.(vname));
  case {'data','orientation'}
    
    
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
    
    varargout{1} = [obj(ind).orientations];
    varargout{2} = ind;
    
    
  case {'quaternions','quaternion'}
    varargout{1} = quaternion();
    for i = 1:length(obj)
      varargout{1} = [varargout{1};reshape(quaternion(obj(i).orientations),[],1)]; 
    end
  case 'length'
    varargout{1} = zeros(1,length(obj));
    for i = 1:length(obj)
      varargout{1}(i) = sum(GridLength(obj(i).orientations));
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
    error('Unknown field in class EBSD!')
end

