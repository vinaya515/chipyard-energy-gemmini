extra               ?=  # extra configs
args                ?=  # command-line args (including step flow control)

vlsi_dir=$(abspath .)
tech_name          = sky130
INPUT_CONFS        = $(vlsi_dir)/custom.yml $(extra)
ENV_YML            = $(vlsi_dir)/custom-env.yml

HAMMER_EXTRA_ARGS   ?= $(foreach conf, $(INPUT_CONFS), -p $(conf)) $(args)

BINARY 				?= /bwrcq/scratch/vinaya/chipyard-energy-gemmini/generators/gemmini/software/gemmini-rocc-tests/build/bareMetalC/tiled_matmul_ws-baremetal
USE_FSDB  		   	= 1
CONFIG				?= LeanGemminiRocketConfig
LOADMEM             = 1
CLOCK_PERIOD       = 16.0 # ns, must match what's in custom.yml, vlsi.inputs.clocks
RESET_DELAY        = 499.5  # 500ns delay 

sim ?= $(OBJ_DIR)/sim-rtl-rundir/simv
binary_name := $(notdir $(basename $(BINARY)))

OUTFILE ?= $(output_dir)/$(binary_name).out

sim-rtl-out:
	set -o pipefail &&  $(sim) +permissive +dramsim +dramsim_ini_dir=$(vlsi_dir)/../generators/testchipip/src/main/resources/dramsim2_ini +max-cycles=$(timeout_cycles)  +ntb_random_seed_automatic +verbose +loadmem=$(BINARY) +permissive-off $(BINARY) </dev/null 2> >(spike-dasm > $(OUTFILE)) | tee $(output_dir)/$(binary_name).log

WAVEFORM_PATH ?= $(call get_sim_out_name,$(BINARY))
sim-rtl-debug-out:
	set -o pipefail &&  $(sim) +permissive +verbose $(call get_waveform_flag,$(WAVEFORM_PATH)) +loadmem=$(BINARY) +dramsim +dramsim_ini_dir=$(vlsi_dir)/../generators/testchipip/src/main/resources/dramsim2_ini +max-cycles=$(timeout_cycles) +permissive-off $(BINARY) </dev/null 2> >(spike-dasm > $(OUTFILE)) | tee $(output_dir)/$(binary_name).log