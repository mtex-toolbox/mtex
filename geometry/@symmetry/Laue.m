function sL = Laue(s)
% return the corresponding Laue group 

% maybe we have alread computed the Laue group
if ~isempty(s.LaueRef)

  sL = s.LaueRef;

elseif s.isLaue % if it is already a Laue group then there is nothing to do
  
  sL = s;

else % in the meantime isLaue has computed the Laue group :)

  sL = s.LaueRef;

end
