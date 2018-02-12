%% Installation Guide
% How to install MTEX on you computer.
%
% 
%% Download
% 
% The MTEX toolbox is available for Windows, Linux, and MAC-OSX at
% <http://mtex-toolbox.github.io/>
% 
%% MATLAB 
%
% Since MTEX is a MATLAB toolbox <http://www.mathworks.com MATLAB> has to
% be installed in order to use MTEX. It works fine with the student version
% and does not require any additional toolboxes, addons or packages. There
% are some very few exceptions like GND and Taylor computation that
% currently require the optimization toolbox to be installed. Check the
% table below to see whether MTEX will run with your Matlab version.
%
% <html>
% <table border=0 align="center">
% <tr><td>Matlab</td>
% <td>2018b</td>
% <td>2018a</td>
% <td>2017b</td>
% <td>2017a</td>
% <td>2016b</td>
% <td>2016a</td>
% <td>2015b</td>
% <td>2015a</td>
% <td>2014b</td>
% <td>2014a</td>
% <td>2013b</td>
% <td>2013a</td>
% <td>2012b</td>
% <td>2012a</td>
% <td>2011b</td>
% <td>2011a</td>
% <td>2010b</td>
% <td>2010a</td>
% </tr>
% <tr>
% <td>MTEX 5.1</td>
% <td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>(&#10004;)</td><td>(&#10004;)</td>
% <td>(&#10004;)</td><td>(&#10004;)</td><td>(&#10004;)</td>
% </tr>
% <tr>
% <td>MTEX 5.0</td>
% <td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>(&#10004;)</td><td>(&#10004;)</td>
% <td>(&#10004;)</td><td>(&#10004;)</td><td>(&#10004;)</td>
% </tr>
% <tr>
% <td>MTEX 4.X</td>
% <td>-</td><td>-</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>(&#10004;)</td><td>(&#10004;)</td>
% <td>(&#10004;)</td><td>(&#10004;)</td><td>(&#10004;)</td>
% </tr>
% <tr>
% <td>MTEX 4.1</td>
% <td>-</td><td>-</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>(&#10004;)</td><td>(&#10004;)</td>
% <td>(&#10004;)</td><td>(&#10004;)</td><td>(&#10004;)</td>
% </tr>
% <tr>
% <td>MTEX 4.0</td>
% <td>-</td><td>-</td>
% <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>(&#10004;)</td><td>(&#10004;)</td>
% <td>(&#10004;)</td><td>(&#10004;)</td><td>(&#10004;)</td>
% </tr>
% <tr>
% <td>MTEX 3.5</td>
% <td>-</td><td>-</td>
% <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% </tr>
% <tr>
% <td>MTEX 3.3</td>
% <td>-</td><td>-</td>
% <td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% <td>&#10004;</td><td>&#10004;</td><td>&#10004;</td>
% </tr>
% </table>
% </html>
%
%% Installation
%
% In order to install, MTEX proceeds as follows
%
% # extract MTEX to an arbitrary folder
% # start MATLAB
% # type into the Matlab command window
%
%   addpath your_MTEX_path
%   startup_mtex
%
%% Configuration and Troubleshooting
%
% You can <configuration.html configure> your MTEX installation by editing
% the file <matlab:edit('mtex_settings.m') mtex_settings.m>. This includes
% also some workarounds for known problems.
%
% Don't hesitate to contact the <mtex_about.html MTEX authors> if you
% have any problems.
%
%% Compiling MTEX
%
% Compiling MTEX is only necessary if the provided binaries do not run on
% your system or if you want to optimize them for your specific system.
% Compiling instructions can be found <compilation.html here>.
%

