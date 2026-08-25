%% Developer Guide: HDF5 EBSD JSON Configurations
%
%%
% Every vendor writes HDF5 differently: the same map is |/EBSD/Data/Euler|
% in one file and |/Site/EBSD/EulerAngles| in the next, and each stores a
% good deal that MTEX does not read. Rather than one importer per vendor,
% MTEX has one importer, <loadEBSD_h5.html |loadEBSD_h5|>, and one JSON
% file per vendor saying where in that vendor's tree each quantity lives.
% They sit in |mtex/interfaces/hdf5_config/| - Bruker, EDAX, EDAXh5,
% EMSphInx, Oxford, ThermoFisher - so supporting a new format means writing
% a configuration, not writing code.
%
% This page describes that configuration language. The reasoning behind the
% individual vendor files - which reference frame a format states, which
% field must not be read and why - is recorded in
% |interfaces/hdf5_config/info.md| next to them.
%
%% How a configuration is read
%
% The reader walks the JSON and the HDF5 tree at the same time. Two
% keywords drive it:
%
% * *|value|* says what to look for, together with a *|mode|* saying where
% to look. The result is a path inside the file.
% * *|type|* says what to do with what was found. It selects a formatting
% function named |<category>_<type>| - |position_direct|,
% |rotation_euler|, |cs_default| - which turns the raw arrays into the
% MTEX objects the @EBSD constructor expects.
%
% Everything else is structure: nested objects mirror the categories the
% constructor needs.
%
%% Where an entry is searched
%
% A |mode| is mandatory on every entry that fetches data, and there are
% four of them.
%
% || *mode* || *searched below* || *matched against* ||
% || |absolute| || nothing, it is the path || the full path, literally ||
% || |search_root| || the enclosing |key| || the full path ||
% || |search_free| || the group *containing* the data set || the full path ||
% || |search_set| || the selected data set || the path *relative* to it ||
%
% |absolute| is right for a rigid layout that never moves. The three search
% modes take a case insensitive regular expression, which survives the
% small renamings between software versions.
%
% |search_free| is the one to reach for when a value sits next to the data
% set rather than inside it - EDAX keeps the step size in a |Sample| group
% beside |EBSD|. |search_set| is the only mode that can tell apart two data
% sets living in the same group, which is what an Oxford file needs, where
% |/1/EBSD| and |/1/Data Processing| are two versions of one map.
%
% An entry may also carry |"optional": true|, so that a file not holding it
% still imports, and a |fallback| value to use instead.
%
%% key and multiple
%
% Two keywords do the structural work.
%
% *|key|* shifts the root. When a container defines one, the group it finds
% becomes the root for everything nested inside, so the inner entries stay
% short and relative. The |ebsd| category's own |key| is what identifies
% the data set to import; it may offer several alternatives as one regular
% expression, and their order is the preference order.
%
% *|multiple|* turns a single match into a list. It is what makes a phase
% list of arbitrary length possible: the |cs| block is evaluated once per
% match instead of once. The number of phases is *implied by the number of
% matches* and not read from the file, so a regular expression that hits
% two data sets of the same phase silently doubles the phase list and
% shifts every phase id of the map. Match exactly one data set per phase.
%
%% The categories
%
% |settings| identifies the vendor - a |key_path| that must exist in the
% file and a |manufacturer_keys| string that must appear in it. This is how
% the importer picks the configuration for a file it is handed.
%
% |ebsd| holds the map itself:
%
% * *|position|* - |type: "direct"| when the file stores an $x$ and a $y$
% per pixel, |type: "indirect"| when it states step sizes and grid
% dimensions instead and the grid has to be built from them.
% * *|rotation|* - |type: "euler"| for three separate angle data sets,
% |type: "euler_stack"| when the three are stacked in one array. Both
% need a |format| of |degree| or |radian|.
% * *|phase|* - the per pixel phase index. |type: "default"| for a file
% that counts phases from one, |"zeroBased"| for one that counts from
% zero, as EMSphInx does, and |"stack"| when the phase map arrives with
% the same shape as the stacked Euler angles.
% * *|cs|* - one crystal symmetry per phase, hence always with
% |"multiple": true|. Its subfields are |name|, |space_group|, |lattice|
% and optionally |reference_frame| and |atoms|. The lattice may be a
% single six element array (|type: "all_together"|), an |angle| and a
% |dim| entry, or six separate entries (|type: "separate"|).
%
% |additions| turns every remaining per pixel data set of a group into a
% property of the map, descending into subgroups and prefixing their names.
% Its |group| may be a list, so that a second analysis of the same site -
% the EDS element maps of an Oxford file - comes along as well. An
% |exclude| list keeps out the ones already read as coordinates.
%
% Any further top level category is metadata and lands under
% |ebsd.opt.<category>|; |eds| and |electron_image| work that way.
%
%% A minimal configuration
%
% This is the ThermoFisher configuration, the smallest of the six, with
% every mandatory piece and nothing else:
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
% Note |"data"| in place of |"mode"| and |"value"|: it injects a constant
% from the configuration instead of reading the file, which is how a fixed
% unit, a fixed crystal reference frame or a fixed grid direction is
% stated.
%
%% Checking a new configuration
%
% |EBSD.load(fname,'headerOnly')| reads the header and lists the data sets
% without touching the per pixel arrays, which is the quick way to see
% whether the |settings| block matched and the |key| found the right group.
% After that the checks of
% <EBSDReferenceFrame.html Reference Frame Alignment> apply: a
% configuration that reads the numbers but puts them in the wrong frame
% produces a map that looks perfectly ordinary.
%
