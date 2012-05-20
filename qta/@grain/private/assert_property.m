function assert_property(grains,property,varargin)

if check_option(varargin,'properties')
  names = fields(grains(1).properties);
else
  names = [fields(grains(1)) ;fields(grains(1).properties)];
end

if ~strcmpi(property,names)
    error(['This function requires ''' property ''' as grain property'])
end
