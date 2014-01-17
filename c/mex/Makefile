#------ Pathes ---------------------------------------------------------------
MATLABPATH ?= /opt/matlab
TARGET ?= glnxa64
MEXFLAGS ?= -largeArrayDims #-compatibleArrayDims

# ----- what to build ---------------------------------------------------------

MEX_TOOLS = buffer.c S1Grid.c S2Grid.c SO3Grid.c
MTEX_MEX = S1Grid_find S1Grid_find_region S2Grid_find S2Grid_find_region SO3Grid_find SO3Grid_find_region SO3Grid_dist_region

#--------------------------------------------------------------------------
all: $(MTEX_MEX)

%: %.c $(MEX_TOOLS)
	$(MATLABPATH)/bin/mex $(MEXFLAGS) -outdir $(TARGET) $<

install:

clean:
