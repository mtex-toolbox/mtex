MTEX - MATLAB toolbox for quantitative texture analysis

Overview
--------

MTEX is a MATLAB toolbox containing the following features

- Analyze and visualize crystallographic geometries
- Calculate with model ODFs
- Import, analyze and visualize arbitrary diffraction data
- Import, analyze and visualize arbitrary individuell orientation mesurements (EBSD)
- Grain and missorientation analysis
- Recover orientation density functions (ODFs)
- Calculate texture characteristics
- Create publication ready plots
- Writting scripts to process many data sets

For an introduction, please have a look at the help first. If the
toolbox is installed the help can be found in the MATLAB help window
which can be opend by typing 'doc mtex'.
For installation instructions, you can also refer to the file INSTALL
in this directory.

Directory structure
-------------------
AUTHORS		      information about the authors of MTEX
c (dir)         source code for core library routines
ChangeLog	      a short version history
COPYING		      information about redistributing MTEX
data (dir)      some sample data sets
examples (dir)  simple examples for using MTEX
geometry (dir)  geometry tools
help (dir)	    user and developer documentation
info.xml        used by MATLAB
istall_mtex     install MTEX for permanent use
INSTALL         installation instructions
MAKEFILE        contains the compiling options !! to be edited by the advanced user !!
mtex_settings   contains the configuration of MTEX !! to be edited by the user !!
qta (dir)       core scripts for working with ODFs, EBSD data, and PDFs
templates (dir) template file for importing EBSD and pole figure data
README          this file
startup.m       initialization routine automticaly called by MATLAB if the
                toolbox is contained in the search path of MATLAB
startup_mtex    initialization routine for MTEX - to be called at the
                beginning of each MTEX session
tests (dir)     some self tests
tools           auxiliary tools
unistall_mtex   remove MTEX from the search path (permanently)


Feedback
--------
Your comments are welcome! MTEX is heavily developed and may not be
as robust or well documented as it should be. Please keep track of bugs or
missing/confusing instructions and report them to

  Dr. Ralf Hielscher <Ralf.Hielscher@gmail.com,Ralf.Hielscher@gmail.com>
  TU Chemnitz
  Fakultät für Mathematik
  Reichenhainer Str.39, Zimmer 710
  D-09107 Chemnitz, GERMANY

  personal homepage: http://www-user.tu-chemnitz.de/~rahi/

  MTEX Homepage: http://code.google.com/p/mtex/

If you find MTEX useful, we would be delighted to hear about what application you are using MTEX for!

Legal Information & Credits
---------------------------
Copyright (C) 2005-2010 Ralf Hielscher & Florian Bachmann

This software was written by Ralf Hielscher and Florian Bachmann.
It was developed at the Institute of Geoinformatics,
Freiberg University of Technology.

MTEX is free software. You can redistribute it and/or modify it under the terms
of the GNU General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later version.
If not stated otherwise, this applies to all files contained in this package and
its sub-directories.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

