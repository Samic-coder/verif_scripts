{## 8. Generate main agent file ##}
{% set agent_filename = agent_name + ".sv" %}
// File: {{ agent_name }}/{{ agent_filename }}
`ifndef {{ agent_name.upper() }}_SV
`define {{ agent_name.upper() }}_SV

class {{ agent_name }} extends uvm_agent;

    {{ agent_name }}_sequencer sqr;
    {{ agent_name }}_driver drv;
    {{ agent_name }}_monitor mon;
    {{ agent_name }}_cfg cfg;

    `uvm_component_utils({{ agent_name }})

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Get configuration from config DB
        if(!uvm_config_db#({{ agent_name }}_cfg)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", "Config must be set for agent")
        end
        
        // Create components based on active/passive mode
        mon = {{ agent_name }}_monitor::type_id::create("mon", this);
        
        if(cfg.is_active == UVM_ACTIVE) begin
            sqr = {{ agent_name }}_sequencer::type_id::create("sqr", this);
            drv = {{ agent_name }}_driver::type_id::create("drv", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect driver to sequencer if active
        if(cfg.is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction

endclass

`endif
