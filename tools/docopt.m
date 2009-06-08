function [doccmd,options,docpath] = docopt
%DOCOPT Web browser for UNIX platforms.
%  DOCOPT is an M-file that you or your system manager can edit
%  to specify the Web browser to use with MATLAB. It is used
%  for the WEB function with the -BROWSER option. It is also used
%  for links to external Web sites from the the Help browser
%  and from Web menu items. DOCOPT applies only to non-Macintosh
%  UNIX platforms.
%
%  DOCCMD = DOCOPT returns a string containing the command that
%  WEB -BROWSER uses to invoke a Web browser. Its default is netscape.
%  Note: Aliases are not supported.
%
%  To use a different browser, edit docopt.m and change line 52:
%
%  51 elseif isunix
%  52%  doccmd = '';
%
%  Remove the comment symbol. In the quotes, enter the command
%  that launches your Web browser, and save the file. For example
%
%  52      doccmd = 'mozilla';
%
%  specifies Mozilla as the Web browser MATLAB uses.
%
%  Copyright 1984-2004 The MathWorks, Inc.
%  The MathWorks, Inc. grants permission for Licensee to modify
%  this file.  Licensee's use of such modified file is subject
%  to the terms and conditions of The MathWorks, Inc. Software License
%  Booklet.
% $Revision: 1.1.6.5 $  $Date: 2004/12/22 20:01:28 $

% Intialize options to empty matrices
doccmd = []; options = []; docpath = [];

% This file automatically defaults to the doccmd shown above
% in the online help text. If you would like to set the doccmd
% default to be different from that shown above, enter it after this
% paragraph.

%---> Start of your own changes to the defaults here (if needed)
%
cname = computer;

if (strncmp(cname,'MAC',3))      % MAC
%  doccmd = '';
%% Options
% = '';
%  docpath = '';
elseif isunix                   % UNIX
%  doccmd = '';
%% Options
% = '';
%  docpath = '';
elseif ispc                     % PC
%  doccmd = '';
%% Options
% = '';
%  docpath = '';
else                            % other
%  doccmd = '';
%% Options
% = '';
%  docpath = '';
end
%---> End of your own changes to the defaults here (if needed)

% ----------- Do not modify anything below this line ---------------
% The code below this line automatically computes the defaults 
% promised in the table above unless they have been overridden.

cname = computer;

if isempty(doccmd)

    if (strncmp(cname,'MAC',3))  % For MAC
        doccmd = '';
    elseif isunix % For Unix
        doccmd = 'firefox';
    end

    % For Windows
   if ispc, doccmd = ''; end

end

if isempty(options)

	% For Unix
	options = '';

	% For Mac
	if (strncmp(cname,'MAC',3)), options = ''; end

	% For Windows
	if ispc, options = ''; end

end

if isempty(docpath)
	docpath = '';
end
