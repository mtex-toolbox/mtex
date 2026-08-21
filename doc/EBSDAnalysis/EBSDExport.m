%% Exporting EBSD Data
%
%%
% MTEX allows you to export EBSD data as <exportEBSD_h5.html HDF5>,
% <exportEBSD_ctf.html ctf>, <exportEBSD_ang.html ang> or
% <EBSD.export_crc.html cpr/crc> files. The syntax is
%
%   ebsd.export('myFile.ctf')
%
% The file format is detected automatically from the extension of the
% specified file name.
%
% Note that information may be lost during export into a format different
% then the import format as not all file formats support all properties.
% The exporters take as much of it along as the format allows: whatever the
% header of the imported file stated is kept in |ebsd.opt.header| and
% written back out, and the Euler angles are written in the reference frame
% the format states them in, so that importing the result reproduces the
% map rather than a rotated copy of it.
%
%% HDF5 - writing into a copy of the imported file
%
% There is no such thing as *the* EBSD HDF5 format - every vendor nests its
% data differently and stores much more than MTEX imports, from the raw
% patterns to the acquisition settings. Writing one from scratch would lose
% all of that. Exporting to HDF5 therefore copies the file the data was
% imported from and writes the changed data into the copy, so the result is
% still a file of the vendor's own format.
%
%   ebsd = EBSD.load('myfile.h5oina')
%   ebsd = ebsd.denoise(halfQuadraticFilter)
%
%   % writes a copy of myfile.h5oina with the denoised orientations in it
%   export(ebsd,'denoised.h5oina')
%
% |EBSD.load| remembers the file and the data sets it read in |ebsd.opt.h5|
% - a different reference file can be named explicitly, and properties MTEX
% computed are added next to the ones the file brought along:
%
%   export(ebsd,'denoised.h5oina','reference','myfile.h5oina')
%
% A reference file is therefore required, and exporting data that did not
% come from an HDF5 file raises an error saying so. Earlier versions wrote a
% flat layout of MTEX's own in that case, but nothing could read it back -
% not MTEX and no vendor tool - so it was removed.
%
% To carry a map between MTEX sessions, save it as a |.mat| file. That keeps
% everything an HDF5 export drops, the reference frames and the imported
% header included.
%
%   save('myFile.mat','ebsd')
%   load('myFile.mat')
%
