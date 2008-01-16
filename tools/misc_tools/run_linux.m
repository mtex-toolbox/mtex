function varargout = run_linux(prg,varargin)
% execute extern program with arguments
%
%% Syntax
%  varargout = run_linux(prg,variable_name,variable_value,...,flags,....)
%
%% Input 
% *prg - command to be executed
% *varaiable_name - name of a variable
% *varaiable_name - value of a variable
%
%% Flags
% *SILENT
% *VERBOSW
% *EXTERN
% *INTERN
%
%% Output
%  varagout - list of output parameters
%

%% check input

if ~exist(prg,'file')
  error(['Can not find ',prg,'! Run "make install"']);
end

%% global flags
global global_computer
global mtex_tmppath;
global mtex_prefix_cmd;
global mtex_postfix_cmd;
global mtex_machineformat;
global mtex_logfile;
global mtex_debug;

%% local flags
inline = 0;
verbose = 0;
silent = 0;
suffix = int2str(100*cputime);
[path, name] = fileparts(prg);
name = [name,suffix];
iname = cell(1,length(varargin)+1);

%% generate parameter file
fid = fopen([mtex_tmppath,filesep,name,'.txt'],'w');
for i=1:nargin-1
	
	if isempty(iname{i}) && ~isempty(inputname(i+1))
		iname{i} = inputname(i+1);
  elseif strcmpi(varargin{i},'SILENT')
		silent = 1;
		continue;
  elseif strcmpi(varargin{i},'VERBOSE')
		verbose = 1;
		continue;
	elseif strcmpi(varargin{i},'EXTERN')
		inline = 0;
		continue;
	elseif strcmpi(varargin{i},'INTERN')
		inline = 1;
		continue;
	elseif isempty(iname{i}) && isa(varargin{i},'char')
		iname{i+1} = varargin{i};
		continue;
	elseif isempty(iname{i})
		error('wrong format - you may have passed an expression and not a variable');
	end
	
	if isempty(varargin{i})
		
		iname{i} = [];
		
	elseif issparse(varargin{i})
		
		vdisp(verbose,['  write files for sparse matrix ',iname{i}]);
		
		[jc,ir,pr] = save_sparse(varargin{i});
		fprintf(fid,'%s_jc: ',iname{i});
		fprintf(fid,[mtex_tmppath,filesep,name,'_',iname{i},'_jc.dat\n']);
		fdata = fopen([mtex_tmppath,name,'_',iname{i},'_jc.dat'],'w');
		fwrite(fdata,jc,'int32');
		fclose(fdata);
		fprintf(fid,'%s_ir: ',iname{i});
		fprintf(fid,[mtex_tmppath,name,'_',iname{i},'_ir.dat\n']);
		fdata = fopen([mtex_tmppath,name,'_',iname{i},'_ir.dat'],'w');
		fwrite(fdata,ir,'int32');
		fclose(fdata);
		fprintf(fid,'%s_pr: ',iname{i});
		fprintf(fid,[mtex_tmppath,name,'_',iname{i},'_pr.dat\n']);
		fdata = fopen([mtex_tmppath,name,'_',iname{i},'_pr.dat'],'w',mtex_machineformat);
		fwrite(fdata,pr,'double');
		fclose(fdata);
		
	elseif inline
			
		vdisp(verbose,['  write inline: ',iname{i}]);
		fprintf(fid,'%s: ',iname{i});
			
		if isa(varargin{i},'int32')
			fprintf(fid,'%d ',varargin{i});
		elseif isa(varargin{i},'uint32')
			fprintf(fid,'%d ',varargin{i});
		elseif isa(varargin{i},'double')
			fprintf(fid,'%.4E ',varargin{i});
		elseif isa(varargin,'char')
			fprintf(fid,'%s ',varargin{i});
		end
		fprintf(fid,'\n');
		iname{i} = [];
		
	else
		
		vdisp(verbose,['  write extern: ',iname{i}]);
		fprintf(fid,'%s: ',iname{i});
		
		d = varargin{i};
		s = whos('d');
		fprintf(fid,[mtex_tmppath,name,'_',iname{i},'.dat\n']);
		fdata = fopen([mtex_tmppath,name,'_',iname{i},'.dat'],'w',mtex_machineformat);
		fwrite(fdata,d,s.class);
		fclose(fdata);
	end
end

for i=1:nargout
	fprintf(fid,['res',int2str(i),': ',mtex_tmppath,name,'_res',int2str(i),'.dat\n']);
end
fclose(fid);


%% run linux command
vdisp(verbose,['  call ',prg]);
cmd = [mtex_prefix_cmd,prg,' ',mtex_tmppath,name,...
  '.txt 2>> ',mtex_logfile,mtex_postfix_cmd];
if ~isempty(global_computer), cmd = ['ssh ',global_computer,' ',cmd];end

if silent
  unix([cmd,' &'],'-echo');
  varargout{1} = @() finish(name,verbose,nargout);
else
  if mtex_debug 
    disp('Stopped because of "mtex_debug"-flag');
    disp(['Files written to ',mtex_tmppath,name]);
    fprintf('You may want to execute the command\n\n%s\n\n',cmd);
    disp('hit enter if finished')
    pause
  else
    status = unix(cmd,'-echo');
    if status ~= 0, error('error running external program:\n\n %s',cmd);end
  end
	
  % get output
  varargout = readdata(name,verbose,nargout);
  
  % check output
  if isempty(varargout{1}) || length(varargout) < nargout   
    error('Error running external program:\n\n %s\n\n To few output files.',cmd);
  end
  
  cleanup(name,verbose);
end
end % function

%% finish
function varargout = finish(name,verbose,nout)
  varargout = readdata(name,verbose,nout);
  if ~isempty(varargout{1})
    cleanup(name,verbose);
  end
end

%% retrieve information
function out = readdata(name,verbose,nout)
global mtex_tmppath;
for i=1:nout
  vdisp(verbose,['  read result file ',int2str(i)]);
  fdata = fopen([mtex_tmppath,name,'_res',int2str(i),'.dat'],'r');
  if fdata == -1
    out{1} = []; %#ok<AGROW>
    return
  end
  out{i} = fread(fdata,'double'); %#ok<AGROW>
  fclose(fdata);
  % delete file
  delete([mtex_tmppath,name,'_res',int2str(i),'.dat']);
end
end

%% cleanup
function cleanup(name,verbose)
global mtex_tmppath;
% delete parameter files
vdisp(verbose,'  delete datafiles:')
delete([mtex_tmppath,name,'.txt']);
delete([mtex_tmppath,name,'_*.dat']);
end

function vdisp(verbose,s)
if verbose, vdisp(verbose,s);end
end
