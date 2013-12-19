function out = check_option(S1G,option)
% return flags

if nargin == 1

  if S1G.periodic
    out = {'periodic'};
  else
    out = {};
  end
  
else  
  out = any(strcmpi(option,'periodic'));
end
