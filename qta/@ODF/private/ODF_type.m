function type = ODF_type(varargin)

type = {'UNIFORM','FOURIER','FIBRE','Bingham','EVEN'};

pos = find_option(type,varargin);
if pos > 0
  type = type{find_option(type,varargin)};
else
  type = ''; 
end

