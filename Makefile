# Copyright (c) 2020-2023 by Albert Bartók and Miguel Caro

SHELL = /bin/sh

# Include user-modifiable variables from a customizable file.
# Check the makefiles/ directory for a list of tested architectures

include makefiles/Makefile.Ubuntu_gfortran_mpi

# Default locations for various files
BUILD_DIR=build
BIN_DIR=bin
INC_DIR=include
LIB_DIR=lib

# Do not change anything below this line
##########################################################

F90_OPTS += $(F90_MOD_DIR_OPT) $(INC_DIR)

PROGRAMS := turbogap


SRC := splines.f90 types.f90 neighbors.f90 gap.f90 vdw.f90		\
	local_properties.f90 exp_utils.f90  xyz.f90 md.f90 mc.f90 read_files.f90	\
	gap_interface.f90 mpi.f90 exp_interface.f90 turbogap_routine.f90

SRC_TP_BT := resamplekin.f90
SRC_ST := soap_turbo_functions.f90 soap_turbo_radial.f90 soap_turbo_angular.f90 \
          soap_turbo.f90 soap_turbo_compress.f90
SRC_STOP := adaptive_time.f90 electronic_stopping.f90 eph_beta.f90 eph_fdm.f90 \
            eph_electronic_stopping.f90

OBJ := $(addprefix $(BUILD_DIR)/,$(patsubst %.f90,%.o,$(SRC)))
OBJ_TP_BT := $(addprefix $(BUILD_DIR)/,$(patsubst %.f90,%.o,$(SRC_TP_BT)))
OBJ_ST := $(addprefix $(BUILD_DIR)/,$(patsubst %.f90,%.o,$(SRC_ST)))
OBJ_STOP := $(addprefix $(BUILD_DIR)/,$(patsubst %.f90,%.o,$(SRC_STOP)))

PROG := $(addprefix $(BIN_DIR)/,$(PROGRAMS))

.SUFFIXES:
.SUFFIXES: .f90 .o
.PHONY: default all programs clean deepclean libturbogap

default: libturbogap programs

all: default

clean:
	rm -rf $(OBJ_STOP) $(OBJ_TP_BT) $(OBJ_ST) $(OBJ) $(INC_DIR)/*.mod $(PROG)

deepclean:
	rm -rf $(BUILD_DIR) $(BIN_DIR) ${INC_DIR} ${LIB_DIR}

.SECONDEXPANSION:
.SECONDARY: $(OBJS)

programs: $(PROG)

libturbogap: $(OBJ_STOP) $(OBJ_TP_BT) $(OBJ_ST) $(OBJ) ${LIB_DIR}
	ar scr $(LIB_DIR)/libturbogap.a $(OBJ_STOP) $(OBJ_TP_BT) $(OBJ_ST) $(OBJ)

$(BIN_DIR)/%: src/%.f90 $(OBJ_STOP) $(OBJ_TP_BT) $(OBJ_ST) $(OBJ) | $$(@D)
	$(F90) $(PP) $(F90_OPTS) $< -o $@ $(OBJ_STOP) $(OBJ_TP_BT) $(OBJ_ST) $(OBJ) $(LIBS)

$(BUILD_DIR)/%.o: src/stopping/%.f90 | $$(@D)
	$(F90) $(PP) $(F90_OPTS) -c $< -o $@
$(BUILD_DIR)/%.o: src/third_party/bussi_thermostat/%.f90 | $$(@D)
	$(F90) $(PP) $(F90_OPTS) -c $< -o $@
$(BUILD_DIR)/%.o: src/soap_turbo/src/%.f90 | $$(@D)
	$(F90) $(PP) $(F90_OPTS) -c $< -o $@
$(BUILD_DIR)/%.o: src/%.f90 | $$(@D)
	$(F90) $(PP) $(F90_OPTS) -c $< -o $@

$(BUILD_DIR): ${INC_DIR}
	mkdir -p $@

$(BIN_DIR):
	mkdir -p $@

$(INC_DIR):
	mkdir -p $@

$(LIB_DIR):
	mkdir -p $@
