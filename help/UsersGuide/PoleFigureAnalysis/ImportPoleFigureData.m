%% Importing Pole Figure Data
% How to import Pole Figure Data
%
%%
% Importing pole figure data in MTEX means to create a
% <PoleFigure_index.html PoleFigure> object from data files containing 
% diffration data. Once such an object has been created the data can be
% <ModifyPoleFigures.html analyzed and processed> in many ways.
% Furthermore, such a PoleFigure object is the starting point for 
% <odf_estimation.html PoleFigure to ODF estimation>.
%
%% Contents
%

%% Import Pole Figure Data Using the Import Wizard
%
% The [[import_wizard.html,import wizard]] can be started either
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
% * <loadPoleFigure_aachen.html Aachen> (<aachen_interface.html example>)
% * <loadPoleFigure_aachen2.html Aachen2>
% * <loadPoleFigure_aachen_exp.html Aachen ASCII data format *.exp *.EXP> (<aachen_exp_interface.html example>)
% * <loadPoleFigure_beartex.html BearTex ASCII data format *.xpe *.xpf> (<beartex_interface.html example>) 
% * <loadPoleFigure_frame.html Bruker ASCII data format *.axs>
% * <loadPoleFigure_cnvindex.html Dubna ASCII data format *.cnv> (<dubna_interface.html example>)
% * <loadPoleFigure_dubna.html Dubna ASCII data format *.cns (interpolated)>
% * <loadPoleFigure_geesthacht.html Geesthacht ASCII data format *.dat > (<geesthacht_interface.html example>)
% * <loadPoleFigure_juelich.html Juelich ASCII data format *.jul> (<juelich_interface.html example>)
% * <loadPoleFigure_nja.html Seifert ASCII data format *.nja>  
% * <loadPoleFigure_out1.html Graz ASCII data format *.out>
% * <loadPoleFigure_philips.html Philips ASCII data format *.txt> (<philips_interface.html example>)
% * <loadPoleFigure_plf.html Queens Univ. PF Format files *.plf>
% * <loadPoleFigure_popla.html popLA ASCII data format *.epf *.gpf>
% * <loadPoleFigure_ptx.html Heilbronner *.ptx *.rpf> (<ptx_interface.html example>)
% * <loadPoleFigure_slc.html *.slc>
% * <loadPoleFigure_xrd.html 'Bruker XRD ASCII data format *.xrd *.ras>
% * <loadPoleFigure_xrdml.html PANalytical XML data format *.xrdml> (<xrdml_interface.html example>)
% * <loadPoleFigure_generic.html plain (theta,rho,intensity) text files>
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
% For an example importing such data see <generic_interface.html here>.
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

