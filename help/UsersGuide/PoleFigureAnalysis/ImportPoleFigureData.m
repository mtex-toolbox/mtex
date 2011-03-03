%% Importing Pole Figure Data
% How to import Pole Figure Data
%
%%
% Importing pole figure data in MTEX means to create a
% <PoleFigure_index.html PoleFigure> object from data files containing
% diffration data. Once such an object has been created the data can be
% <ModifyPoleFigureData.html analyzed and processed> in many ways.
% Furthermore, such a PoleFigure object is the starting point for
% <PoleFigure2odf.html PoleFigure to ODF estimation>.
%
%% Contents
%

%% Import pole figure data using the import wizard
%
% The <import_wizard.html import wizard> can be started either
% by typing into the command line

import_wizard

%%
% or using from the start menu the item
% *Start/Toolboxes/MTEX/Import Wizard* or by clicking rigth on a
% data file and choosing *import*. The import
% wizard provides a gui to import data of almost all data formats MTEX
% currently supports and to specify crystal symmetry, Miller indece and
% structure coefficients. The gui allows to plot the imported data, save
% them as a <PoleFigure_index.html PoleFigure> object to the workspace or to
% generate a m-file loading the data automatically.
%
%% List of automatically detected interfaces
%
% The following formats are currently supported by MTEX. If you have any
% comments, remarks or request on interfaces please contact us.
%
% <html>
%   <table class="refsub" width="90%">
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_ana.html" class="toplink">*.ana</a>
%    </td>
%    <td valign="top"> EMSE ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_dubna.html" class="toplink">*.cns</a>
%    </td>
%    <td valign="top"> Dubna ASCII pole figure format, regular grid.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_cnvindex.html" class="toplink">*.cnv</a>
%    </td>
%    <td valign="top"> Dubna ASCII pole figure format,
%    experimental grid.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_geesthacht.html" class="toplink">*.dat</a>
%    </td>
%    <td valign="top"> Geesthacht ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_popla.html"
%      class="toplink">*.epf, *.gpf </a>
%    </td>
%    <td valign="top"> Popla ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_labotex.html"
%      class="toplink">*.epf, *.ppf, *.pow </a>
%    </td>
%    <td valign="top"> LaboTEX ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_aachen_exp.html" class="toplink">*.exp</a>
%    </td>
%    <td valign="top"> Aachen ASCII pole figure format.</td>
%  </tr>
%   <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_ibm.html" class="toplink">*.ibm</a>
%    </td>
%    <td valign="top"> IBM ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_juelich.html" class="toplink">*.jul</a>
%    </td>
%    <td valign="top"> Juelich ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_nja.html" class="toplink">*.nja</a>
%    </td>
%    <td valign="top"> Seifert ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_out1.html" class="toplink">*.out</a>
%    </td>
%    <td valign="top"> Graz ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_plf.html" class="toplink">*.plf</a>
%    </td>
%    <td valign="top"> Queens Univ. ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_ptx.html" class="toplink">*.ptx, *.rpf</a>
%    </td>
%    <td valign="top"> Heilbronner ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_philips.html" class="toplink">*.txt</a>
%    </td>
%    <td valign="top"> Philips ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_beartex.html" class="toplink">*.xpe, *.xpf</a>
%    </td>
%    <td valign="top"> BearTex ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_slc.html" class="toplink">*.slc</a>
%    </td>
%    <td valign="top"> SLC ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_xrd.html" class="toplink">*.xrd, *.ras</a>
%    </td>
%    <td valign="top"> Bruker XRD ASCII pole figure format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_xrdml.html" class="toplink">*.xrdml</a>
%    </td>
%    <td valign="top"> PANalytical XML data format.</td>
%  </tr>
%  <tr>
%    <td width="15" valign="top"></td>
%    <td width="250px" valign="top">
%      <a href="loadPoleFigure_aachen.html" class="toplink">*.*</a>
%    </td>
%    <td valign="top"> Aachen ASCII pole figure format.</td>
%  </tr>
%   </table>
% </html>
%
%% Importing pole figure data using the method loadPoleFigure
%
% Diffraction data that are stored in one of the formats listed above can
% also be imported using the command <loadPoleFigure.html loadPoleFigure>.
% It automatically detects the data format and imports the data. In
% dependency of the data format it might be neccesary to specify the Miller
% indices and the structure coefficients. The general syntax is

cs = symmetry('-3m',[1.4,1.4,1.5]); % crystal symmetry
ss = symmetry('triclinic');         % specimen symmetry

% specify file names
fnames = {...
  [mtexDataPath '/dubna/Q(10-10)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(10-11)(01-11)_amp.cnv']};

% specify crystal directions
h = {Miller(1,0,-1,0,cs),[Miller(0,1,-1,1,cs),Miller(1,0,-1,1,cs)]};

% specify structure coefficients
c = {1,[0.52 ,1.23]};

% load data
pf = loadPoleFigure(fnames,h,cs,ss,'superposition',c)

% plot the data
plot(pf)

%%
% See <loadPoleFigure.html loadPoleFigure>
% for futher information or follow the above links for an example of each data
% format.
%
%% Importing pole figure data from general ascii files
%
% MTEX function <loadPoleFigure_generic.html loadPoleFigure_generic> provides an
% easy way to import diffraction data from txt files that are of the
% following format
%
%  theta_1 rho_1 intensity_1
%  theta_2 rho_2 intensity_2
%  theta_3 rho_3 intensity_3
%     .      .       .
%     .      .       .
%     .      .       .
%  theta_M rho_M intensity_M
%
% The txt files may contain an arbitrary number of header lines, columns or
% comments and the actual order of the columns may specified by options.
% For an example importing such data see <loadPoleFigure_generic.html loadPoleFigure_generic>.
%
%
%% Importing pole figure data from unknown formats
%
% MTEX also provides a way to import data from formats currently not
% supported directly. Therefore you can to use all standard MATLAB input
% and output commands to read the pole figure informations, e.g. intensities,
% specimen directions, crystal directions directly from the data files.
% Then you have to call the constructor
% [[PoleFigure_PoleFigure.html,PoleFigure]] with these data to generate
% a PoleFigure obejct.
%
%% Writing your own interface
%
% Once you have written an interface that reads data from certain data
% files and generates a PoleFigure object you can integrate this method
% into MTEX by copying it into the folder |MTEX/qta/interfaces|. Then
% it will be automatical called by the methods loadPoleFigure and
% import_wizard. Examples how to write such an interface can be found in
% the directory |MTEX/qta/interfaces|.
%

