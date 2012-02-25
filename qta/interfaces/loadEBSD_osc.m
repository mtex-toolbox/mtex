function ebsd = loadEBSD_osc(fname,varargin)
%

[path,file,ext]= filparts(fname);


if strncmp(ext,'.osc',4)
  
  
  [data,Xstep,Ystep] = Osc2Ang( fname );
  ignore = all(data(:,1:3) >= 2*pi,2);
  data = data(~ignore,:);
  
  data = double(data);
  q = euler2quat(data(:,1),data(:,2),data(:,3),'bunge');
  
  phase = data(:,8);
  opt.x = data(:,4);
  opt.y = data(:,5);
  opt.iq = data(:,6);
  opt.ci = data(:,7);
  opt.sem_signal =  data(:,9);
  opt.fit = data(:,10);
  
  unitCell = [ Xstep/2 -Ystep/2;  Xstep/2  Ystep/2;  -Xstep/2  Ystep/2;  -Xstep/2 -Ystep/2];
  
  ebsd = EBSD(q,symmetry('cubic'),symmetry,'phase',phase,'unitCell',unitCell,'options',opt);
  
end
%% taken from ANYSTITCH
%
% A.L. PILCHAK, A.R. SHIVELEY, J.S. TILEY, and D.L. BALLARD,
% AnyStitch: a tool for combining electron backscatter diffraction data sets.
% Journal of Microscopy, 244 (1), 2011, pp. 38-44.
%
% More complete documentation can be found in the User's manual and in the
% Journal of Microscopy article itself.
%
% adam.pilchak@wpafb.af.mil
% adam.shiveley@wpafb.af.mil
%
%% BSD License:
%  * ================================================================================
%  * Copyright (c) 2011, Adam L. Pilchak, Adam R. Shiveley (USAF Research Laboratory)
%  * All rights reserved.
%  *
%  * Redistribution and use in source and binary forms, with or without modification,
%  * are permitted provided that the following conditions are met:
%  *
%  * Redistributions of source code must retain the above copyright notice, this
%  * list of conditions and the following disclaimer.
%  *
%  * Redistributions in binary form must reproduce the above copyright notice, this
%  * list of conditions and the following disclaimer in the documentation and/or
%  * other materials provided with the distribution.
%  *
%  * Neither the name of the software, AnyStitch, nor the names of its contributors may
%  * be used to endorse or promote products derived from this software without
%  * specific prior written permission from Adam L. Pilchak.
%  *
%  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
%  * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
%

function [ RelevantData,Xstep,Ystep ] = Osc2Ang( OscFile )
%  [RelevantData,Xstep,Ystep ] = Osc2Ang(OscFile) reads the *.osc file
%  whose path is defined by the string OscFile into a variable RelevantData in the matlab workspace.
%  The X and Y step sizes are also extracted.
%
%   The variable RelevantData contains all of the data normally found in
%   an *.ang file
%
%
%% Open the Current Osc for reading as binary
fid = fopen(OscFile,'rb');

% read the data stored in the .osc file as 8 bit
data = transpose( fread( fid, '*bit8' ) );

% Search the data read in from the .osc for the starting
% location of the real data in the .osc.  The data at this point
% is an array of ascii values.  Searching for this unqiue
% grouping will locate the beginning of the Relevant Data.
%%% NOTE: This string may change in other versions of TSL OIM
start_euler_indices = strfind(data,[-71 11 -17 -1 2]);

% Search the data from the .osc, in 8 bits, for
% the location of the eurler angles.  The .osc always has 3 or
% more matches with this command.  The first match is the
% location of the first phase, but parsing the data out for the
% first phase requires converting between *bit8, hex, and
% readable strings.  The second match, as with TSL 5.2 and TSL
% 5.3 contains the starting location of the real data.  The 3
% match contains the ending location of the real data.  Any
% other matches in this array indicate ending locations for the
% Hough Transfomrs. This may change for later versions.
end_euler_indices = strfind(data, [-71 11 -17 -1]);
end_euler = end_euler_indices(find(end_euler_indices == start_euler_indices)+1);
euler_angles_ascii = data(start_euler_indices:end_euler-1);

% Reshape the euler data into arrays, 4 chracters in
% length to be used in the typecast function
final_euler_angles = reshape(euler_angles_ascii,[4,length(euler_angles_ascii)/4]);

% Typecast the data into a readable number
RelevantData = typecast(final_euler_angles(:), 'single');

% Collect the values for Xstep and Ystep, from the .osc file
Xstep = RelevantData(3);
Ystep = RelevantData(4);

% Delete the first four data points because they are no longer used
RelevantData(1:4) = [];

% Break the data up into an array that resembles the .ang
% file format being sure to transpose
RelevantData = reshape(RelevantData, [10,length(RelevantData)/10])';

% Close the currently open .osc file
fclose(fid);

