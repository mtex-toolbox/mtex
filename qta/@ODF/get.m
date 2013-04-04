function varargout = get(obj,vname,varargin)
% extract data from an ODF object
%
%% Syntax
%   s = get(odf,'CS')            % crystal symmetry
%   w = get(odf,'weights')       % weights of the texture components
%   k = get(odf,'kernel')        % get kernel of unimodal and fibre portions
%   c = get(odf,'center')        % center of the components 
%   y = get(odf,'kappa')         % Bingham coefficients
% 
%% Input
%  odf - @ODF
%
%% Output
%  w - double
%  s - @symmetry 
%  k - @kernel
%  x,y,p,m - double
%
%% See also
% ODF/set


%% no vname - return list of all fields
if nargin == 1
	vnames = get_obj_fields(obj(1));
  vnames = [vnames;{'resolution';'weights';'kernel';'kappa'}];
  if nargout, varargout{1} = vnames; else disp(vnames), end
  return
end


%% switch fieldnames
switch vname
  case {'CS','SS','comment','options'}
    varargout{1} = obj(1).(vname);
    
  case 'symmetry'
    varargout{1} = obj(1).CS;
    varargout{2} = obj(1).SS;
    
  case {'weights','weight'}
    
    for i=1:length(obj)
      w(i) = sum(obj(i).c(:)); %#ok<AGROW>
    end
    varargout{1} = w;
    
  case 'kernel'
    
    if isa(obj(1).psi,'kernel')
      varargout{1} = [obj.psi];
    end
    
  case 'kappa'
    
    varargout{1} = obj(1).psi;
    
  case fields(obj)
    varargout{1} = obj(1).(vname);
    
  case 'resolution'
    try
      k = [obj.psi];
      hw = get(k,'halfwidth');
      varargout{1} = min(hw);
    catch %#ok<CTCH>
      varargout{1} = 5*degree;
    end
  otherwise
    error(['There is no ''' vname ''' property in the ''ODF'' object'])
end

