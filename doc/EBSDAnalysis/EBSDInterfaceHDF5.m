%% Developer Guide: HDF5 EBSD JSON Configurations
%
% This interface dynamically translates manufacturer-specific HDF5 structures 
% (Bruker, EDAX, Oxford, ThermoFisher) into a unified MTEX |EBSD| object. 
% The |.json| configuration file acts as a precise roadmap, instructing 
% the script where to look for metadata and how to format the extracted arrays.
%
%% 1. The Core Concept: Dynamic Tree Searching
%
% The script processes the configuration file completely *recursively* % via the |readConf| function. It traverses the JSON layout while 
% simultaneously navigating the metadata tree of the opened HDF5 file:
%
% * Every major category (|position|, |rotation|, |cs|, etc.) is evaluated 
%   relative to a *|root|* path (defaulting to the discovered main EBSD group).
% * When the script encounters the |"value"| keyword, it invokes |get_hdf5_path| 
%   to resolve the actual target dataset or group path inside the file.
% * When it finds the |"type"| keyword, it dynamically looks for a matching 
%   MATLAB formatting function named |[category]_[type]| (e.g., |position_direct| 
%   or |rotation_euler|) to convert the raw data into MTEX-compatible objects.
%
%% 2. The Three Search Modes (mode)
%
% Any field responsible for fetching or defining data must explicitly state 
% its operational mode using one of the following options:
%
% * *|absolute|* : Bypasses any search architecture and utilizes the exact string path 
%   provided. Highly recommended for rigid, unchanging standard file structures.
%   _Example:_ |"value": "/Site/Acquisition/StepSize"|
% * *|regex|* : Executes a case-insensitive regular expression search within the 
%   current HDF5 subtree. Protects against minor naming variations across software versions.
%   _Example:_ |"value": "^X Position$"|
% * *|data|* : Bypasses HDF5 file reading entirely and injects the hardcoded value 
%   straight from the JSON layout. Perfect for fixed units, formatting definitions, or static matrices.
%   _Example:_ |"value": "degree"|
%
%% 3. Main Category Specifications
%
% The JSON configuration file must directly mirror the structure expected by the 
% core MTEX |EBSD| constructor. The following formatters are natively supported:
%
%%
% * Spatial Coordinates (position)*
%
% * *|type: "direct"|* : Used when the HDF5 file stores explicit coordinate arrays 
%   for each individual measurement pixel.
%   _Required subfields:_ |x| and |y|.
% * *|type: "indirect"|* : Used when explicit coordinates are omitted, requiring a grid 
%   generation (|meshgrid|) calculated from header metrics (step sizes and map dimensions).
%   _Required subfields:_ |step_size_x|, |step_size_y|, |grid_size_x|, |grid_size_y|.
%
%%
% * Spatial Orientations (rotation)*
%
% * *|type: "euler"|* : Handles classic three-angle orientation inputs.
%   _Required subfields:_ |formate| (must resolve to |"degree"| or |"radiante"|) 
%   alongside either individualized axis entries (|phi1|, |Phi|, |phi2|) or a single 
%   bundled orientation matrix (|phi|).
% * *|type: "euler_stack"|* : Handles single 3D data arrays where orientation angles are 
%   stacked sequentially along the first matrix dimension.
%   _Required subfields:_ |formate| and |phi|.
% * *|type: "correctById"| / |type: "correctByAngle"|* : Applies custom mathematical 
%   transformations or rotations to align the physical detector coordinate frame with the mapping system.
%
%%
% * Crystal Symmetry (cs)*
%
% The parser dynamically accommodates multi-phase materials by tracking and creating 
% independent cell array entries for each validated mineral phase group.
%
% * *|type: "default"|* : Feeds extracted properties directly into the MTEX |crystalSymmetry| constructor.
%   _Crucial flag:_ Always include |"multiple": "true"| to instruct the script to collect 
%   all available phases sequentially.
%   _Required subfields:_ |name|, |group| (space group or point group matching |type: "space"|), 
%   and |lattice| parameters.
%   Lattice properties can be parsed collectively as a compact 6-element array (|type: "all_together"|) 
%   or completely decoupled using |type: "seperate"|.
%
%% 4. Advanced Navigation: "key" & "multiple"
%
% Two structural JSON properties drive the core automation behaviors of the parser:
%
% * *|"key"| (Contextual Root Shift)* : When an object container (such as |cs|) defines 
%   a |"key"| field, the script locates this group in the HDF5 tree and enforces it as the 
%   new localized *|root|* for all nested subfields. This keeps inner definitions like |name| 
%   or |lattice| modular, eliminating the need to provide absolute parent pathways.
% * *|"multiple": "true"|* : Instructs the |readConf| loop not to abort after the first regex match, 
%   but to accumulate all matching nodes into a cell array. This forms the operational backbone for 
%   seamlessly indexing an arbitrary number of mineral phases.
%
%% 5. Minimal Integration Template
%
% When extending support to a new vendor format, use this clean layout as your baseline 
% and adjust the regex target patterns to match your manufacturer's specific naming conventions:
%
%  {
%    "settings": {
%      "ebsd_key": {"mode": "regex", "value": "Main_EBSD_Group_Name"}
%    },
%    "position": {
%      "type": "direct",
%      "direct": {
%        "x": { "mode": "regex", "value": "^X_Axis_Label$" },
%        "y": { "mode": "regex", "value": "^Y_Axis_Label$" }
%      }
%    },
%    "phase": {"mode": "regex", "value": "Phase_Map_Dataset", "type": "default"},
%    "rotation": {
%      "type": "euler",
%      "euler": {
%        "formate": {"data": "degree"},
%        "phi1": { "mode": "regex", "value": "Euler_1" },
%        "Phi":  { "mode": "regex", "value": "Euler_2" },
%        "phi2": { "mode": "regex", "value": "Euler_3" }
%      }
%    },
%    "cs": {
%      "type": "default",
%      "multiple": "true",
%      "key": { "mode": "regex", "value": "Phases_Metadata_Folder" },
%      "default": {
%        "group": { "mode": "regex", "value": "SpaceGroup_Field", "type": "space" },
%        "name": { "mode": "regex", "value": "MineralName_Field"},
%        "lattice": { "mode": "regex", "value": "Lattice_Array_Field", "type": "all_together"}
%      }
%    },
%    "additions": {
%      "type": "auto",
%      "key": { "mode": "regex", "value": "Additional_Metadata_Folder"}
%    }
%  }
%
