function varargout = get_obj_fields(obj,varargin)


vnames = fieldnames(obj);
for k=1:numel(varargin)
  if isfield(struct(obj),varargin{k})
    vnames = [vnames; fieldnames(struct(obj).(varargin{k}))];
  end
end

if nargout > 0, 
  varargout{1} = vnames;
else
  disp(vnames);
end
