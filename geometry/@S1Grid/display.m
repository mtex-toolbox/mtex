function display(S1G,varargin)
% standart output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('S1Grid_index','S1Grid') ...
    ' ' docmethods(inputname(1))]);
end

disp([' size: ' num2str(GridLength(S1G))]);
disp([' min: ',num2str([S1G.min])]);
disp([' max: ',num2str([S1G.max])]);
if S1G(1).periodic, disp(' periodic: true'); end

 
