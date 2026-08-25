%% Options
%
%%
% Most MTEX commands take options: a name as a string, followed by its
% value. They are always optional, they may be given in any order, and they
% come after the arguments the command actually needs.
%
% The plotting commands all understand |'resolution'|, which says how finely
% a function is evaluated before it is drawn.

odf = SantaFe
plotPDF(odf,Miller(1,0,0,odf.CS),'resolution',10*degree,'contour','linewidth',2);

%%
% The same at 2.5 degrees:

plotPDF(odf,Miller(1,0,0,odf.CS),'resolution',2.5*degree,'contour','linewidth',2);

%%
% The same three maxima in both, but at 10 degrees the contour lines are
% visibly polygonal - the evaluation grid showing through as kinks - and at
% 2.5 degrees they are smooth curves. What the resolution decides is whether
% the drawing is limited by the function or by the grid it was evaluated on.
% Finer costs time, so the default is a compromise worth overriding for a
% figure that will be published.

%% Flags
%
% An option that takes no value is a flag - |'contour'| above, which asked
% for contour lines instead of a smooth plot. Flags and options mix freely
% in any order.
%
% If the same option is given twice, the *later* one wins, which is what
% makes it possible to write a wrapper that passes on |varargin| and still
% overrides one of its own defaults.

%% Two traps
%
% A misspelt option is silently ignored. There is no list of valid names to
% check against - each command reads the ones it knows and passes the rest
% on - so |calcGrains(ebsd,'theshold',10*degree)| runs, and quietly uses the
% default threshold. This exact typo survived for years in a published
% tutorial because the default happened to be the value that was meant.
% Copy option names rather than typing them.
%
% The second: options are matched case insensitively but not by meaning, so
% |'colorRange'| and |'colorrange'| are the same option while
% |'colourRange'| is not an option at all.
%
% Which options a command understands is in its own help, which for MTEX
% commands lists them under *Options* and *Flags*:
%
%   doc calcGrains
