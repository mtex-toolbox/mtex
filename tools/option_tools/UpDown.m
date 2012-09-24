function out = UpDown(in)

UD = {'outOfPlane','intoPlane'};

if nargin == 0
  out = UD;
elseif isnumeric(in)
  out = UD{in};
elseif ischar(in)
  ind = strcmpi(in,UD);
  out = find(ind);
else
  error('Input must be a string or a number!');
end

