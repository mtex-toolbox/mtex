function display(S1G,varargin)
% standart output

displayClass(S1G,inputname(1),varargin{:});

disp([' size: ' num2str(GridLength(S1G))]);
disp([' min: ',num2str([S1G.min])]);
disp([' max: ',num2str([S1G.max])]);
if S1G(1).periodic, disp(' periodic: true'); end

 
