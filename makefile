PRJ     = lightpwm
TCL_DIR = ./scripts
TMP_DIR = ./tmp
RTL_DIR = ./rtl
TB_DIR  = ./tb
XDC_DIR = ./xdc
GLBL    = "C:/Xilinx/Vivado/2016.4/data/verilog/src/glbl.v"

RTL      = $(wildcard $(RTL_DIR)/*.v)
TB       = $(wildcard $(TB_DIR)/*.v)
IP       = $(wildcard $(TCL_DIR)/ip_*.tcl)
DAT      = $(wildcard $(TB_DIR)/*.dat*)
IP_NAMES = $(subst ;,,$(foreach script, $(IP), $(word 2, $(subst _, ,$(script)));))
XDC      = $(XDC_DIR)/arty.xdc
IP_DONE  = $(foreach script, $(IP), $(TMP_DIR)/$(script).ip.done)

.PHONY: all clean ip sim ipsim setup compile

all : setup

setup : $(TMP_DIR)/$(PRJ).setup.done
$(TMP_DIR)/$(PRJ).setup.done : $(RTL) $(XDC) $(IP_DONE)
	cmd /c "vivado -mode batch -source $(TCL_DIR)/setup_$(PRJ).tcl \
	-log $(TMP_DIR)/setup_$(PRJ).log \
	-jou $(TMP_DIR)/setup_$(PRJ).jou"

ip : $(IP_DONE)
$(IP_DONE) :
	cmd /c "vivado -mode batch -source $(TCL_DIR)/$(basename $(basename $(notdir $@))) \
	-log $(TMP_DIR)/$(basename $(basename $(basename $(notdir $@)))).log \
	-jou $(TMP_DIR)/$(basename $(basename $(basename $(notdir $@)))).jou"

compile : $(TMP_DIR)/$(PRJ).compile.done
$(TMP_DIR)/$(PRJ).compile.done : $(TMP_DIR)/$(PRJ).setup.done
	cmd /c "vivado -mode batch -source $(TCL_DIR)/compile_$(PRJ).tcl \
	-log $(TMP_DIR)/$(PRJ).compile.log \
	-jou $(TMP_DIR)/$(PRJ).compile.jou"

$(TMP_DIR)/sim_rtl.done : $(TMP_DIR)/sim_ip.done 
	$(foreach f, $(TB), (cd $(TMP_DIR) && xvlog -work xil_defaultlib "../../$(subst ../,,$(f))");)
	$(foreach f, $(RTL), (cd $(TMP_DIR) && xvlog -work xil_defaultlib "../../$(subst ../,,$(f))");)
	cmd /c "cd $(TMP_DIR) && xvlog -work xil_defaultlib $(GLBL)"
	touch $(TMP_DIR)/sim_rtl.done

ipsim : $(TMP_DIR)/sim_ip.done
$(TMP_DIR)/sim_ip.done: $(IP_DONE)
	$(foreach ipname, $(IP_NAMES),\
	 	$(if $(wildcard $(TMP_DIR)/ip/$(ipname)_sim/xsim/vlog.prj),\
		(cd $(TMP_DIR) && xvlog -prj $(subst workdir,.,$(subst ../,,$(wildcard $(TMP_DIR)/ip/$(ipname)_sim/xsim/vlog.prj))));))
	$(foreach ipname, $(IP_NAMES),\
	 	$(if $(wildcard $(TMP_DIR)/ip/$(ipname)_sim/xsim/vhdl.prj),\
		(cd $(TMP_DIR) && xvhdl -prj $(subst workdir,.,$(subst ../,,$(wildcard $(TMP_DIR)/ip/$(ipname)_sim/xsim/vhdl.prj))));))
	touch $(TMP_DIR)/sim_ip.done
	
sim: $(TMP_DIR)/sim_ip.done $(TMP_DIR)/sim_rtl.done
	$(foreach dat, $(DAT), (cp $(dat) $(TMP_DIR));)
	(cd $(TMP_DIR) && xelab -L xil_defaultlib -L unisims_ver xil_defaultlib.$(PRJ)_tb xil_defaultlib.glbl -s $(PRJ)_sim)
	(cd $(TMP_DIR) && xsim $(PRJ)_sim -t ../scripts/$(PRJ)/xsim_$(PRJ).tcl)

clean :	
	find $(TMP_DIR) -not -name "$(notdir $(TMP_DIR))" | xargs rm -rf
