function flags = calc_flags(args,flagbits)
% check for optional flag
%
% Input
%  varargin -
%  list {flag_name,bit_position} - 
%
% Output
%  bitsum -

if check_option(args,'FLAGS')
  flags = get_option(args,'FLAGS');
else
  flags = 0;
  for i = 1:length(flagbits)
    flags = flags + check_option(args,flagbits{i}{1}) * 2^flagbits{i}{2};
  end
end

flags = uint32(flags);
