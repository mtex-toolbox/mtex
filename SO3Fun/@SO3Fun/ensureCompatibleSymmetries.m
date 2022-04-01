function ensureCompatibleSymmetries(SO3F1,SO3F2,varargin)
% For calculating with @SO3Fun (+, -, .*, ./, conv, ...) we have to verify
% that the symmetries are suitable.
%

if (SO3F1.SRight ~= SO3F2.SRight) || (SO3F1.SLeft ~= SO3F2.SLeft)
  error('Calculations with @SO3Fun''s are not supported if the symmetries are not compatible.')
end

end