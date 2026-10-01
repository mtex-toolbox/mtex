%% Data From Your Instrument
%
%%
% MTEX reads the files of every major EBSD vendor, of 3D diffraction and
% of microstructure simulation into one data model, and writes EBSD maps
% back out in the vendors' own formats. This page lists, vendor by vendor,
% which files that covers, how the Euler angles are aligned with the map,
% and the line that imports them.
%
% The alignment matters most. A vendor may describe the Euler
% angles and the map positions in two different specimen frames, and not
% every file states how the two are related. Where the file is silent, MTEX
% assumes the alignment the vendor uses by default and prints a note saying
% so. <EBSDReferenceFrame.html Reference Frame Alignment> shows how to check
% that assumption against a feature of the specimen.
%
%% Overview
%
% || *Vendor* || *Software* || *MTEX reads* || *MTEX writes* ||
% || Oxford Instruments || AZtec, Channel 5 || .ctf, .cpr/.crc, .h5oina || .ctf, .cpr/.crc, .h5oina ||
% || EDAX || OIM, APEX || .ang, .osc, .oh5, .h5, .edaxh5 || .ang, .oh5, .h5, .edaxh5 ||
% || Bruker || ESPRIT || .h5 || .h5 ||
% || Thermo Fisher || xTalView || .h5 || .h5 ||
% || NanoMegas (ACOM-TEM) || ASTAR || .ang || – ||
% || Xnovo || GrainMapper3D || .h5 || – ||
% || BlueQuartz || DREAM.3D || .dream3d || – ||
% || Neper || Neper || .tess || – ||
% || open source || EMSphInx || .h5, .ang || .h5 ||
%
% An HDF5 file is written by updating a copy of the imported file, so
% it keeps the vendor's header and acquisition settings; see
% <EBSDExport.html Exporting EBSD Data>. A text file of columns from any
% other source is read by the <loadEBSD_generic.html generic loader>.
%
%% Oxford Instruments
%
% AZtec writes |.h5oina| and, like Channel 5, the text format |.ctf| and
% the binary pair |.cpr| and |.crc|.
%
%   ebsd = EBSD.load('map.h5oina');
%   ebsd = EBSD.load('map.ctf');
%   ebsd = EBSD.load('map.cpr');
%
% An |.h5oina| file states its scan rotation, and MTEX applies it. For
% |.ctf| and |.cpr| MTEX assumes the Oxford default, Euler angles turned by
% 180° about the z axis against the map. A file exported with another
% alignment is imported with that rotation stated explicitly:
%
%   ebsd = EBSD.load('map.ctf','EulerCorrection',rotation.id);
%
% An |.h5oina| file may hold the raw and the processed version of a map;
% <EBSDImport.html Importing EBSD Data> shows how to choose between them.
%
%% EDAX
%
% OIM and APEX write the text format |.ang|, the binary |.osc| and HDF5.
%
%   ebsd = EBSD.load('map.ang');
%   ebsd = EBSD.load('map.osc');
%   ebsd = EBSD.load('map.oh5');
%   ebsd = EBSD.load('map.edaxh5');
%
% EDAX chooses the alignment of Euler angles and map at export time, as
% one of four _settings_. An |.oh5| file states the setting. An |.ang|,
% |.osc| or |.edaxh5| file does not, and MTEX assumes setting 2, the most
% common one.
% Another setting is passed by number, and |'setting',0| switches the
% correction off:
%
%   ebsd = EBSD.load('map.ang','setting',3);
%
%% Bruker
%
% ESPRIT writes HDF5.
%
%   ebsd = EBSD.load('map.h5');
%
% The file states its coordinate system, and MTEX applies the matching
% alignment.
%
%% Thermo Fisher
%
% xTalView writes HDF5.
%
%   ebsd = EBSD.load('map.h5');
%
% xTalView writes the map with its x axis opposite to the specimen x axis
% the Euler angles refer to. MTEX applies the matching alignment, a half
% turn about the y axis.
%
%% NanoMegas ASTAR (ACOM-TEM)
%
% ASTAR exports its orientation maps from the |.res| results as |.ang|
% files. MTEX recognises them by their first header line and reads the
% positions in nanometres.
%
%   ebsd = EBSD.load('map.ang');
%
% As for EDAX |.ang| files, the alignment of Euler angles and map is not
% stored; check the assumed setting 2 against the specimen before relying
% on directions in the map.
%
%% 3D data: Xnovo, DREAM.3D and Neper
%
% Volumes measured with Xnovo GrainMapper3D (LabDCT) and voxel data from
% DREAM.3D are imported as an <EBSD3.EBSD3.html |EBSD3|> volume, grain
% meshes from DREAM.3D and tessellations from Neper as
% <grain3d.grain3d.html |grain3d|> grains.
%
%   ebsd = EBSD3.load('volume.h5');
%   ebsd = EBSD3.load('volume.dream3d');
%   grains = grain3d.load('mesh.dream3d');
%   grains = grain3d.load('tessellation.tess');
%
% Xnovo states positions in millimetres and DREAM.3D in micrometres, and
% MTEX keeps those units. <EBSD3Analysis.html 3D EBSD Analysis>,
% <Dream3dGrains.html DREAM.3D Grain Meshes> and
% <NeperInterface.html Neper Interface> continue from here.
%
%% X-ray and neutron pole figures
%
% Pole figures are read from the files of Malvern Panalytical (X'Pert,
% |.xrdml|), Rigaku (SmartLab), Bruker and Siemens (D5000), Seifert and
% Scintag diffractometers, from the neutron diffractometers at Dubna,
% Geesthacht and Jülich, and from the texture programs popLA, BEARTEX and
% LaboTex.
%
%   pf = PoleFigure.load('measurement.xrdml');
%
% <PoleFigureImport.html Importing Pole Figure Data> covers the formats
% and the crystal symmetry a pole figure file needs.
%
%% Next
%
% <EBSDImport.html Importing EBSD Data> explains what an import produces
% and what it cannot guess, and <EBSDReferenceFrame.html Reference Frame
% Alignment> how to verify the alignment before trusting any
% specimen-relative result.
