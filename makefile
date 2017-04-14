mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
PRJ     = $(current_dir)
TCL_DIR = ./scripts
IP_DIR  = ./ip
TMP_DIR = ./tmp
TMP_IP_DIR = .tmp/ip
RTL_DIR = ./rtl
TB_DIR  = ./tb
XDC_DIR = ./xdc
GLBL    = "C:/Xilinx/Vivado/2016.4/data/verilog/src/glbl.v"

RTL      = $(wildcard $(RTL_DIR)/*.v)
TB       = $(wildcard $(TB_DIR)/*.v)
IP       = $(notdir $(wildcard $(IP_DIR)/*.tcl))
DAT      = $(wildcard $(TB_DIR)/*.dat*)
IP_DONE  = $(foreach script, $(IP), $(TMP_DIR)/$(script).ip.done)
IP_NAMES = $(foreach script, $(IP), $(basename $(notdir $(script))))
XDC      = $(XDC_DIR)/arty.xdc

.PHONY: all clean ip sim ipsim setup compile

all : setup

# add project name to scripts templates
$(TMP_DIR)/setup.tcl:
	cmd /c "echo set project $(PRJ) | cat - $(TCL_DIR)/setup.tcl > $(TMP_DIR)/setup.tcl"
$(TMP_DIR)/compile.tcl:
	cmd /c "echo set project $(PRJ) | cat - $(TCL_DIR)/compile.tcl > $(TMP_DIR)/compile.tcl"

# run setup script
setup : $(TMP_DIR)/$(PRJ).setup.done
$(TMP_DIR)/$(PRJ).setup.done : $(RTL) $(XDC) $(IP_DONE) $(TMP_DIR)/setup.tcl
	cmd /c "vivado -mode batch -source $(TMP_DIR)/setup.tcl \
	-log $(TMP_DIR)/setup_$(PRJ).log \
	-jou $(TMP_DIR)/setup_$(PRJ).jou"

# genrate IPs with scripts
ip : $(IP_DONE)
$(IP_DONE) :
	cmd /c "vivado -mode batch -source $(IP_DIR)/$(basename $(basename $(notdir $@))) \
	-log $(TMP_DIR)/$(basename $(basename $(basename $(notdir $@)))).log \
	-jou $(TMP_DIR)/$(basename $(basename $(basename $(notdir $@)))).jou"

# run compile script
compile : $(TMP_DIR)/$(PRJ).compile.done
$(TMP_DIR)/$(PRJ).compile.done : $(TMP_DIR)/$(PRJ).setup.done $(TMP_DIR)/compile.tcl
	cmd /c "vivado -mode batch -source $(TMP_DIR)/compile.tcl \
	-log $(TMP_DIR)/$(PRJ).compile.log \
	-jou $(TMP_DIR)/$(PRJ).compile.jou"

# process all rtl and tb files through 'xvlog'
# no vhdl here, implement if needed
$(TMP_DIR)/sim_rtl.done : $(TMP_DIR)/sim_ip.done 
	$(foreach f, $(TB), (cd $(TMP_DIR) && xvlog -work work "../$(subst ../,,$(f))");)
	$(foreach f, $(RTL), (cd $(TMP_DIR) && xvlog -work work "../$(subst ../,,$(f))");)
	cmd /c "cd $(TMP_DIR) && xvlog -work work $(GLBL)"
	touch $(TMP_DIR)/sim_rtl.done

# process every project existing for gererated IPs in 'xvlog' and 'xvhdl'
# some IPs have both projects others have only one
ipsim : $(TMP_DIR)/sim_ip.done
$(TMP_DIR)/sim_ip.done: $(IP_DONE)
	@echo "HERE!!!"
	@echo $(subst $(notdir $(TMP_DIR)),.,$(subst ../,,$(wildcard $(TMP_IP_DIR)/$(ipname)_sim/xsim/vlog.prj)))
	$(foreach ipname, $(IP_NAMES),\
	 	$(if $(wildcard $(TMP_IP_DIR)/$(ipname)_sim/xsim/vlog.prj),\
		(cd $(TMP_DIR) && xvlog -prj $(subst $(notdir $(TMP_DIR)),.,$(subst ../,,$(wildcard $(TMP_IP_DIR)/$(ipname)_sim/xsim/vlog.prj))));))
	$(foreach ipname, $(IP_NAMES),\
	 	$(if $(wildcard $(TMP_IP_DIR)/$(ipname)_sim/xsim/vhdl.prj),\
		(cd $(TMP_DIR) && xvhdl -prj $(subst $(notdir $(TMP_DIR)),.,$(subst ../,,$(wildcard $(TMP_IP_DIR)/$(ipname)_sim/xsim/vhdl.prj))));))
	touch $(TMP_DIR)/sim_ip.done
	
# since IPs use unknown libraries we get full list of generated directories
# and pass them as options for 'xelab'
LIBS=$(basename $(notdir $(shell find ./tmp/xsim.dir -maxdepth 1 -type d)))
LLIBS=$(foreach lib, $(LIBS), -L $(lib))
sim: $(TMP_DIR)/sim_ip.done $(TMP_DIR)/sim_rtl.done
	$(foreach dat, $(DAT), (cp $(dat) $(TMP_DIR));)
	(cd $(TMP_DIR) && xelab $(LLIBS) -L unisims_ver work.$(PRJ)_tb work.glbl -s $(PRJ)_sim)
	(cd $(TMP_DIR) && xsim $(PRJ)_sim -t ../$(TCL_DIR)/xsim.tcl)

# just clean all files in tmp dir
clean :	
	find $(TMP_DIR) -not -name "$(notdir $(TMP_DIR))" | xargs rm -rf
