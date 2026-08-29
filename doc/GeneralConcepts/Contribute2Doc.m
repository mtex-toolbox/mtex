%% Contributing to the MTEX documentation
%
% MTEX documentation is maintained by the whole community. Useful
% contributions include spelling corrections, worked examples, theoretical
% explanations and special use cases. Contributors automatically appear on
% the <https://github.com/mtex-toolbox/mtex/graphs/contributors GitHub
% contributors page>.
%
% Each help page is an executable MATLAB script. A good change must therefore
% improve the explanation and leave the example runnable.

%% Choose an editing route
% A small correction to one page is easiest in GitHub's web editor. Work
% locally when the change contains executable code, affects several pages or
% needs a visual preview. Both routes end with a pull request against the
% development branch.

%% Edit one page online
% Work through these steps in order:
%
% # Sign in to <https://github.com GitHub>.
% # Open the help page you want to change.
% # Follow its *edit page* link to the corresponding file in the MTEX
% repository. For example, open
% <https://github.com/mtex-toolbox/mtex/blob/develop/doc/GeneralConcepts/Contribute2Doc.m
% this page's source>.
% # Choose the pencil icon in the top right corner, then edit or paste the
% corrected text.
% # Select *Commit changes* or *Propose changes*. GitHub creates a fork when
% you do not have write access to the MTEX repository.
% # Give the change a short description, select *Propose changes*, and create
% the pull request.
%
% The button labels can differ slightly between GitHub views. The important
% outcome is a pull request whose base repository is |mtex-toolbox/mtex| and
% whose base branch is |develop|.

%% Work on a page in MATLAB
% Documentation sources live below the |doc| directory. Open a page by its
% filename or relative path when MTEX is on the MATLAB path:
%
%   edit doc/GeneralConcepts/Contribute2Doc.m
%
% The editor lets you run each section, investigate the effect of different
% parameters or input files, and add further analysis steps. Run the complete
% script before submitting it because later sections may depend on variables
% created earlier.
%
% A page begins with its title as a |%%| section. Prose uses comment lines,
% while uncommented lines are executed and published as code. Use pipes for
% inline code, as in |calcGrains|, and include the |.html| suffix in internal
% links, as in <ClusterDemo.html Clustering>.

%% Make figures earn their place
% A generated figure belongs immediately after the code that creates it. Add
% a sentence that tells the reader what feature or comparison to notice.
%
% Use a static PNG or SVG only when MATLAB cannot draw the concept clearly.
% The same file must exist in |doc/makeDoc/general| for offline help and in
% |~/mtex/web/images| for the website. An image present in only one location
% is missing from the other build.

%% Preview and validate the change
% The MATLAB <https://www.mathworks.com/help/matlab/matlab_prog/publishing-matlab-code.html
% |publish|> command provides a quick, raw preview:
%
%   publish filename
%
% It creates an |html| folder in the current directory. This preview is useful
% for basic MATLAB markup, but it does not apply the MTEX website publisher's
% link handling, navigation or image sizing.
%
% If the website checkout is available, preview the selected page from its
% |matlab| directory:
%
%   makeDoc('doc','file','Contribute2Doc')
%
% Run the page itself before previewing it, and run the structural checker from
% the MTEX repository root:
%
%   run doc/GeneralConcepts/Contribute2Doc.m
%   python3 doc/tools/check_doc_structure.py
%
% A full website build republishes every page and rebuilds the navigation. It
% is much slower and should be reserved for an attended final check.

%% Submit a reviewable change
% A documentation pull request should say what confused the reader, summarize
% the correction and list the page run or preview used as evidence. Include a
% before-and-after image when the rendered figure changes.
%
% If the documentation accompanies a user-visible feature or syntax change,
% update the <changelog.html MTEX release notes> as well. Ordinary spelling and
% clarity fixes do not need a release-note entry.
%
% You may also copy a local change into GitHub's web editor as described above,
% or send it to an MTEX developer by email. A pull request is preferable
% because it keeps the discussion and the exact change together.

%% References
% * GitHub,
% <https://docs.github.com/en/repositories/working-with-files/managing-files/editing-files
% Editing files>, documents the web editor, automatic fork and pull-request
% workflow used above.
% * MathWorks,
% <https://www.mathworks.com/help/matlab/matlab_prog/publishing-matlab-code.html
% Publishing MATLAB code>, defines the raw |publish| preview and its output.
