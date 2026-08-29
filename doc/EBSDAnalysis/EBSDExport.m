%% Exporting EBSD Data
%
%%
% Exporting writes an @EBSD map to another file. Begin with a map whose
% phases and <EBSDReferenceFrame.html reference frame> have already been
% checked. <EBSDImport.html Importing EBSD Data> introduces the properties,
% scan-level options and header information discussed below.
%
% <EBSD.export.html |export|> chooses the exporter from the filename
% extension.
%
%   % write an Oxford text file
%   export(ebsd,'myFile.ctf');
%

%% Choose the output for its purpose
%
% No EBSD file format can represent every part of an MTEX variable. A
% *property* has one value per measurement and is subset with the map. A
% *header* is scan-level information from the imported file, such as
% acquisition settings and vendor bookkeeping. It remains in the vendor's
% native layout under |ebsd.opt.header|.
%
% || *Output* || *Use* || *Important limit* ||
% || <exportEBSD_ang.html |.ang|> or <exportEBSD_ctf.html |.ctf|> || vendor text exchange || fixed columns and format-specific header entries only ||
% || <EBSD.export_crc.html |.crc| / |.cpr|> || Oxford binary exchange || writes the paired files but not EDS data ||
% || <exportEBSD_h5.html HDF5 extensions> || return changed data to a vendor container || requires the imported HDF5 provenance and a reference file ||
% || another extension, such as |.txt| || a plain numeric table || writes Euler angles, phase ids and numeric properties, but not a complete map archive ||
% || MATLAB |.mat| || move the complete MTEX variable between MTEX sessions || not a vendor-neutral exchange format ||
%
% Converting between formats can therefore lose or rename properties,
% header entries, phase descriptions and acquisition data. Keep the
% original measurement file, write to a new name and re-import the result
% before relying on it.
%
% The |.ang| and |.ctf| exporters undo the correction applied by the
% corresponding importer between the Euler-angle and map reference frames.
% This preserves the specimen-frame interpretation when the same setting is
% used on import. It does not guarantee that another format can represent
% the same crystal frame attached to each phase.
%
% Both exporters take as much of the rest along as the format allows:
% whatever the header of the imported file stated is kept in
% |ebsd.opt.header| and written back out, so entries MTEX does not model -
% the pattern centre, the working distance, the operator - are carried over
% rather than written as zeros.
%
%% Verify a text-format conversion
%
% This example converts a bundled CTF map to ANG and imports the new file.
% The two object summaries are useful output: compare the measurement and
% phase inventories, then inspect which per-pixel properties the target
% format retained.

mtexdata twins

exportFile = [tempname '.ang'];
export(ebsd,exportFile,'silent');
ebsdRoundTrip = EBSD.load(exportFile)

isIndexed = ebsd.isIndexed & ebsdRoundTrip.isIndexed;
roundTripError = max(angle(ebsd(isIndexed).orientations, ...
  ebsdRoundTrip(isIndexed).orientations)) / degree

%%
% Both summaries contain 22,879 measurements: 22,833 indexed magnesium
% measurements and 46 notIndexed measurements. Their property lists differ
% because ANG and CTF define different columns. A missing property name does
% not always mean that its values vanished. The exporter may map a compatible
% quantity to the target format's name.
%
% The import warning concerns the relationship between the Euler-angle and
% map reference frames. Export and import both use ANG setting 2 here, so
% that relationship is consistent. The measured |roundTripError| is
% $30^\circ$, which exposes another loss.
%
% The original CTF phase uses X parallel to a-star and Y parallel to b. The
% ANG import supplies X parallel to a and Y parallel to b-star. The two files
% do not carry the same hexagonal crystal frame. A successful import and equal
% measurement counts are therefore not enough to validate a converted map.

delete(exportFile);

%% HDF5: write into a copy of the imported file
%
% HDF5 is a container, not one EBSD data format. Every vendor defines its
% own hierarchy, units and data sets. A vendor file may also contain raw
% diffraction patterns, electron images and acquisition settings that MTEX
% never imported. Creating a new hierarchy from the @EBSD variable would
% discard those contents.
%
% The HDF5 exporter instead copies the file from which the map was imported
% and patches the changed values into that copy. The output remains in the
% vendor's layout.
%
%   ebsd = EBSD.load('myfile.h5oina');
%   ebsd = ebsd.denoise(halfQuadraticFilter);
%
%   % copy myfile.h5oina and replace its orientations
%   export(ebsd,'denoised.h5oina');
%
% <EBSD.load.html |EBSD.load|> records the source file and resolved data-set
% paths in the scan-level option |ebsd.opt.h5|. A different reference file
% can be named explicitly, but the @EBSD variable must still carry that HDF5
% provenance. The named file must contain the recorded paths.
%
%   export(ebsd,'denoised.h5oina', ...
%     'reference','myfile.h5oina');
%
% The output and reference filenames must differ. The exporter refuses to
% overwrite the reference because a failed write would destroy the only
% complete copy.
%
% Only measurements that remain in the @EBSD variable are patched. Other
% rows remain as the reference file stored them. So does every data set that
% MTEX did not read.
%
% The exporter updates orientations, phases, phase names and lattice values.
% It does not translate point-group symmetry between vendor coding schemes.
% Per-pixel numeric properties return to their original paths. Header contents
% that MTEX does not model survive because the reference file is copied.
%
% A property computed in MTEX is added beside the imported properties when
% the vendor layout has an extensible data group. A compound record has no
% room for another column. The exporter warns and leaves that property out.
% Pass |'noProp'| to update orientations and phases while leaving every
% property in the reference copy unchanged.
%
% A reference file is required. Data that was not imported from HDF5 has no
% record of the paths to patch. Supplying another HDF5 filename still raises
% an error. Earlier versions wrote a flat MTEX-specific HDF5 layout instead.
% Nothing could read that layout back, so it was removed.
%
%% Preserve the complete MTEX variable
%
% Use a MAT-file to carry the map between MTEX sessions. It preserves the
% full variable, including properties, scan-level options, reference frames
% and the imported header.
%
%   save('myFile.mat','ebsd');
%   load('myFile.mat');
%
% A MAT-file is the lossless MTEX working copy, not a substitute for the
% original acquisition file or a documented interchange format. Preserve
% those alongside it when the data must remain usable outside MTEX.
%
%% References
%
% * <https://www.iso.org/standard/82749.html ISO 24173:2024>, _Microbeam analysis -- Guidelines for
% orientation measurement using electron backscatter diffraction_, concerns reliable and reproducible measurements.
% * M. A. Jackson et al., <https://doi.org/10.1186/2193-9772-3-4 h5ebsd: an archival data format for
% electron back-scatter diffraction data sets>, _Integrating Materials and Manufacturing Innovation_ 3, 44--55, 2014.
% The paper distinguishes archival and workflow files.
% * The <https://support.hdfgroup.org/documentation/hdf5/latest/_h5_d_m__u_g.html HDF5 Data Model and
% File Structure> explains why HDF5 supplies containers and objects rather than an EBSD-specific hierarchy.
% * The <https://github.com/oinanoanalysis/h5oina/blob/master/H5OINAFile.md Oxford Instruments
% NanoAnalysis HDF5 File Specification> documents one vendor hierarchy, including units and coordinate definitions.
%
%% Next
%
% Export completes the EBSD file workflow. Continue with <Grains.html Grains>
% to measure reconstructed grains. <GrainBoundaries.html Grain Boundaries>
% treats their interfaces. <ODFAnalysis.html ODF Analysis> describes the
% orientation distribution.
