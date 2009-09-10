function value = get(obj,vname,varargin)
% get object variable

value = [];
switch vname
  case 'CS'
    if check_option(varargin,'all')
      value = [obj.(vname)];
    else
      value = obj(1).(vname);
    end    
  case {'comment','SS','options'}
    value = obj(1).(vname);
  case fields(obj)
    value = vertcat(obj.(vname));
  case {'data','orientation'}
    value = [obj.orientations];
  case {'quaternions','quaternion'}
    value = quaternion();
    for i = 1:length(obj)
      value = [value;reshape(quaternion(obj(i).orientations),[],1)]; %#ok<AGROW>
    end
  case 'length'
    value = zeros(1,length(obj));
    for i = 1:length(obj)
      value(i) = sum(GridLength(obj(i).orientations));
    end
  case 'x'
    for i = 1:length(obj)
      value = [value;obj(i).xy(:,1)]; %#ok<AGROW>
    end
  case 'y'
    for i = 1:length(obj)
      value = [value;obj(i).xy(:,2)]; %#ok<AGROW>
    end
  case fields(obj(1).options)
     options = [obj.options];
     value = vertcat(options.(vname));    
%     for i = 1:length(obj)
%       value = [value;reshape(obj(i).options.(vname),[],1)]; %#ok<AGROW>
%     end
  otherwise
    error('Unknown field in class EBSD!')
end

