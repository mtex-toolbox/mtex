function varargin = set_option_property(obj,varargin)

if check_option(varargin,'property')

  data = get_option(varargin,'property');
  if ischar(data)
    varargin = delete_option(varargin,data);
    data = get(obj,data);     
  end
  
  varargin = set_option(varargin,'property',data);

end
