%% Developer Guide: HDF5 EBSD JSON Configurations
%
%%
% HDF5 is a container, not a single EBSD file format. One vendor may store
% Euler angles at |/EBSD/Data/Euler| and another at
% |/Site/EBSD/EulerAngles|. Each may also store much that MTEX does not read.
%
% MTEX therefore uses one importer, <loadEBSD_h5.html |loadEBSD_h5|>, and a
% JSON configuration for each supported layout. The configurations are in
% |interfaces/hdf5_config/|: Bruker, EDAX, EDAXh5, EMSphInx, Oxford and
% ThermoFisher. Supporting another HDF5 layout usually means adding a
% configuration, not another importer.
%
% This page is for developers writing or reviewing those configurations.
% For ordinary data import, begin with <EBSDImport.html Importing EBSD Data>.
% You should already understand HDF5 groups, data sets and attributes, JSON
% syntax and regular expressions. The
% <https://support.hdfgroup.org/documentation/hdf5/latest/_h5_d_m__u_g.html
% HDF5 data model> introduces the file-tree terminology.
%
% The configuration says where values live and how to turn them into an
% @EBSD variable. It does not settle whether the vendor's Euler-angle,
% crystal and specimen frames have been interpreted correctly. That
% separate check is taught in <EBSDReferenceFrame.html Reference Frame
% Alignment>.
%
% The reasoning behind the existing vendor files is recorded in
% |interfaces/hdf5_config/info.md| beside them. Keep format-specific
% decisions there, especially why a field must not be read or which
% reference frame a vendor states.
%
%% A development workflow
%
% Start from the supported configuration whose tree most closely resembles
% the new file. Give the copy a new |settings.name|. The
% importer discovers every |.json| file in |interfaces/hdf5_config/|, so no
% separate registration step is needed for an extension that already uses
% the HDF5 interface.
%
% First inspect an unsupported file with MATLAB's |h5disp| or |h5info|.
% Define |settings| and the |ebsd.key| before asking MTEX to read it:
% |headerOnly| cannot select a configuration until |settings| matches.
%
% Once detection works, use
% |EBSD.load(fname,'headerOnly','debug',true)|. The debug trace shows which
% path each configuration entry resolved to. Then run a full import and
% inspect the phase ids, position and orientation counts, properties and
% reference frames. A formatter warning is a failed field, not a successful
% partial validation.
%
%% How the reader evaluates a configuration
%
% The reader walks the JSON object and the HDF5 tree together. A normal leaf
% combines two decisions:
%
% * *|value|* says what path to match, while *|mode|* says where and how to
% search. The result is a path inside the HDF5 file.
% * *|type|* selects what to do with the value. It dispatches to a formatter
% named |<category>_<type>|, such as |position_direct|, |rotation_euler| or
% |cs_default|. The formatter returns the MTEX object or array required by
% the @EBSD constructor.
%
% Nested objects mirror the constructor categories. A node may instead use
% |group| to collect the data sets of a group, |data| to inject a constant,
% or |load| to reuse a value cached earlier. Those forms do not perform the
% usual |mode| and |value| leaf search.
%
%% Where an entry is searched
%
% Every path expression has a |mode|. The four names below are copied from
% |loadEBSD_h5|.
%
% || *mode* || *searched below* || *matched against* ||
% || |absolute| || nothing; the value is the path || the full path, literally ||
% || |search_root| || the enclosing |key| || the full path ||
% || |search_free| || the group containing the selected map || the full path ||
% || |search_set| || the selected map itself || the path relative to it ||
%
% |absolute| is a case-sensitive literal path. It is appropriate for a
% rigid layout that never moves. The three search modes use case-insensitive
% regular expressions, which can survive small renamings between software
% versions. Anchor a regular expression whenever an accidental longer match
% would be harmful.
%
% |search_free| is the mode to use when a value sits beside the selected
% map instead of inside it. EDAX, for example, keeps the step size in a
% |Sample| group beside |EBSD|.
%
% |search_set| is the only mode that distinguishes maps living in the same
% enclosing group.
% Oxford may store one map under |/1/EBSD| and a processed version under
% |/1/Data Processing|. A relative expression such as |^/Data/Phase$|
% resolves against the selected one and cannot drift into its neighbour.
%
% Here, a *selected map* means the EBSD acquisition chosen by the
% |dataSet| import option. It is not an HDF5 data set in the narrower sense
% of an array stored at one HDF5 path.
%
%% Structural and control keywords
%
% *|key|* shifts the root for a branch. The matching group becomes the root
% for every nested entry, so their expressions can stay short. The
% |ebsd.key| identifies candidate maps. It may contain alternatives in one
% regular expression; their order is the preference order.
%
% *|multiple|* turns one match into a list. The phase description uses it so
% that the |cs| block is evaluated once per phase. The number of phases is
% implied by the number of matches and is not read separately from the
% file. A regular expression that matches two data sets for one phase
% silently doubles the phase list and shifts every phase id in the map.
% Match exactly one data set per phase.
%
% *|optional|* allows a missing path or branch to be skipped. By contrast,
% *|fallback|* supplies a value when its path is missing and therefore also
% makes that lookup optional. Use a fallback only when the substituted value
% is valid for every file covered by the configuration.
%
% *|data|* supplies a constant from the JSON instead of reading the file.
% It is how a fixed angular unit, grid direction or crystal frame is stated.
% *|group|* reads all data sets directly below a matched group; additions
% also descend into subgroups.
%
% *|safe|* caches a value under its field name. A later *|load|* entry names
% that cached field, optionally followed by a subfield. This avoids reading
% the same compound data set twice, as in |EDAXh5.json|.
%
%% The categories
%
% |settings| identifies the vendor layout. Its |key_path| must resolve, and
% the value read there must contain one of the strings in
% |manufacturer_keys.data|. That field may be one string or a list.
%
% |ebsd| holds the map itself:
%
% * *|position|* uses |type: "direct"| when the file stores an $x$ and a $y$
% for every measurement. It uses |type: "indirect"| when step sizes and grid
% dimensions must be expanded into positions.
% * *|rotation|* uses |type: "euler"| for separate angle arrays,
% |type: "euler_stack"| for one stacked array, or |type: "byMatrix"| for
% orientation matrices. Euler input needs |format: "degree"| or
% |format: "radian"|.
% * *|phase|* is the per-measurement phase index. |type: "default"| preserves
% one-based ids, |type: "zeroBased"| converts the zero-based EMSphInx
% convention, and |type: "stack"| flattens a stacked phase array.
% * *|cs|* creates one crystal symmetry per phase and therefore normally has
% |"multiple": true|. Its fields are |name|, |space_group|, |lattice| and,
% when supplied by the format, |reference_frame| and |atoms|. The lattice
% may be one six-element array with |type: "all_together"|, an |angle| and a
% |dim| array, or six entries with |type: "separate"|.
% * *|header|* collects the scan-level header. A header contains acquisition
% settings and vendor bookkeeping in the file's native field layout. It
% becomes |ebsd.opt.header| rather than a per-measurement property.
% * *|unitCell|* can preserve the vendor's step-size hint. *|map_correction|*
% relates the Euler-angle and map reference frames, while *|how2plot|* states
% how the map frame is laid out on screen.
%
% A *property* has one value per measurement and is subset with the map.
% |additions| turns every remaining per-measurement data set of a group into
% a property, descending into subgroups and prefixing their names. Its
% |group| may be a list, so a second analysis of the same site, such as the
% EDS element maps in an Oxford file, can be imported too. An |exclude| list
% keeps out values already read as coordinates or another core category.
%
% An *option* is scan-level data and is not resized when the map is subset.
% Every further top-level category is stored under |ebsd.opt.<category>|;
% |eds| and |electron_image| use this path. Mark such a category optional
% when the vendor does not write it in every file.
%
% A crystal |reference_frame| entry fixes the Cartesian frame attached to a
% phase's lattice. It is distinct from the phase's point-group symmetry and
% from the specimen-frame correction in |map_correction|. Reading the right
% Euler numbers with the wrong one of these frames still gives a plausible
% but physically misaligned map.
%
%% A minimal configuration
%
% The ThermoFisher configuration is the smallest of the six. It uses
% literal paths for its rigid outer tree, builds positions from the grid
% dimensions, reads stacked phases and Euler angles, and repeats the crystal
% symmetry branch once per phase.
%
%  {
%    "settings": {
%      "name": "ThermoFisher",
%      "key_path": { "mode": "absolute", "value": "/Info/SoftwareVersion" },
%      "manufacturer_keys": { "data": "xTalView" }
%    },
%    "ebsd": {
%      "type": "default",
%      "key": { "mode": "absolute", "value": "/Site/EBSD" },
%      "position": {
%        "type": "indirect",
%        "indirect": {
%          "step_size_x": { "mode": "absolute", "value": "/Site/Acquisition/StepSize" },
%          "step_size_y": { "mode": "absolute", "value": "/Site/Acquisition/StepSize" },
%          "grid_size_x": { "mode": "absolute", "value": "/Site/Acquisition/MapWidth" },
%          "grid_size_y": { "mode": "absolute", "value": "/Site/Acquisition/MapHeight" },
%          "first": { "data": "x" }
%        }
%      },
%      "phase": { "mode": "search_root", "value": "Phase", "type": "stack" },
%      "rotation": {
%        "type": "euler_stack",
%        "euler_stack": {
%          "format": { "data": "degree" },
%          "phi": { "mode": "search_root", "value": "EulerAngles" }
%        }
%      },
%      "cs": {
%        "type": "default",
%        "multiple": true,
%        "key": { "mode": "search_root", "value": "/EBSD/Phase" },
%        "default": {
%          "reference_frame": { "data": "X||a*, Z||c" },
%          "space_group": { "mode": "search_root", "value": "SpaceGroupNumber", "type": "default" },
%          "name": { "mode": "search_root", "value": "Name" },
%          "lattice": {
%            "angle": { "mode": "search_root", "value": "LatticeAngles" },
%            "dim": { "mode": "search_root", "value": "LatticeParameters" }
%          }
%        }
%      }
%    }
%  }
%
% The |data| entries in this example are constants. In particular, the
% crystal-frame string states X parallel to a-star and Z parallel to c; it
% is not a symmetry declaration.
%
% JSON permits neither comments nor trailing commas. Keep explanatory notes
% in |info.md| rather than in the configuration itself. The formal syntax is
% specified by <https://www.rfc-editor.org/info/rfc8259 RFC 8259>.
%
%% Check the configuration without reading the map
%
% This bundled EMSphInx file exercises configuration detection, map
% selection and header construction without reading the per-measurement
% arrays.

fname = [mtexEBSDPath filesep 'EMSphinx.h5'];
ebsdHeader = EBSD.load(fname,'headerOnly');
ebsdHeader.CSList
ebsdHeader.phaseMap
fieldnames(ebsdHeader.opt.header)

%%
% The output identifies EMSphInx, lists four maps and marks |Scan 1/EBSD| as
% selected. The phase list contains |notIndexed| and three indexed phases.
% The phase map and the native header-field names are also visible, while no
% per-measurement array has been read. These inventories are the purpose of
% the check, so they are deliberately displayed.
%
% Next perform a full import with the new configuration. Confirm that every
% property has one value per measurement and that phase ids address the
% intended crystal symmetries. Then apply the known-direction checks from
% <EBSDReferenceFrame.html Reference Frame Alignment>. A map that looks
% ordinary is not evidence that its frames are correct.
%
% A full HDF5 import also records the resolved source paths in
% |ebsd.opt.h5|. <EBSDExport.html Exporting EBSD Data> uses that provenance
% to write changed values into a copy of the vendor file.
%
%% References
%
% * The HDF Group,
% <https://support.hdfgroup.org/documentation/hdf5/latest/_h5_d_m__u_g.html
% HDF5 Data Model and File Structure>, defines groups, data sets, attributes
% and absolute paths.
% * T. Bray, editor, <https://www.rfc-editor.org/info/rfc8259 RFC 8259: The
% JavaScript Object Notation Data Interchange Format>, Internet Standard 90,
% 2017, defines the JSON syntax accepted by MATLAB's |jsondecode|.
% * M. A. Jackson et al., <https://doi.org/10.1186/2193-9772-3-4 h5ebsd: an
% archival data format for electron back-scatter diffraction data sets>,
% _Integrating Materials and Manufacturing Innovation_ 3, 44--55, 2014,
% distinguishes a vendor-neutral archival EBSD layout from workflow files.
% * The
% <https://github.com/oinanoanalysis/h5oina/blob/master/H5OINAFile.md Oxford
% Instruments NanoAnalysis HDF5 File Specification> documents a public
% vendor layout, including units, required data sets and coordinate frames.
