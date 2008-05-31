#------ Pathes ---------------------------------------------------------------
MATLABPATH ?= /opt/matlab
INSTALLPATH ?= ../../geometry
MEXFLAGS ?= -compatibleArrayDims#-largeArrayDims

# ----- NFFT library ---------------------------------------------------------

MEX_TOOLS = buffer.c S1Grid.c S2Grid.c SO3Grid.c
MTEX_MEX = S1Grid_find S1Grid_find_region S2Grid_find S2Grid_find_region SO3Grid_find SO3Grid_find_region SO3Grid_dist_region quaternion_mtimes quaternion_mtimes_qq quaternion_dot_outer

# -----------------------------------------------------------------------------
all: $(MTEX_MEX)

%: %.c $(MEX_TOOLS) 
	$(MATLABPATH)/bin/mex $(MEXFLAGS) $< 

install:
	mv S1Grid*.mex* $(INSTALLPATH)/@S1Grid/private/
	mv S2Grid*.mex* $(INSTALLPATH)/@S2Grid/private/
	mv SO3Grid*.mex* $(INSTALLPATH)/@SO3Grid/private/
	mv quaternion*.mex* $(INSTALLPATH)/@quaternion/private/
clean:
