function v = rdivide(v,a)
% overload pointwise division ./

if ~isnumeric(a)
  error(['For tangent vectors, there is no division method. ' ...
    'It is only possible to divide by numbers.'])
end

v = times(v,1./a);

end
