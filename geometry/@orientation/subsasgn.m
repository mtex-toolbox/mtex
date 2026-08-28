function o = subsasgn(o,s,b)
% overloads subsasgn
%
% Everything is handed to @rotation. What happens here is the note a frame
% assignment leaves: MTEX writes o.CS inside its own methods, and a property
% written inside a class method does not come through subsasgn at all - so
% this is where a line somebody wrote can be told from the bookkeeping,
% without asking the call stack on every assignment MTEX makes.

if isstruct(s) && strcmp(s(1).type,'.') && ...
    (strcmp(s(1).subs,'CS') || strcmp(s(1).subs,'SS'))
  frameAssigned(s(1).subs);
end

o = subsasgn@rotation(o,s,b);

end
