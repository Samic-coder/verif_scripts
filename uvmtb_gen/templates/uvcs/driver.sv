// UVM Driver Template
// Auto-generated from YAML configuration

`ifndef {{ agent.name | upper }}_DRIVER_SV
`define {{ agent.name | upper }}_DRIVER_SV

class {{ agent.name }}_driver extends uvm_driver #({{ agent.name }}_seq_item);
    
    // Configuration handle
    {{ agent.name }}_cfg m_cfg;
    
    `uvm_component_utils({{ agent.name }}_driver)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#({{ agent.name }}_cfg)::get(this, "", "m_cfg", m_cfg)) begin
            `uvm_fatal("NOCFG", {"Configuration must be set for: ", get_full_name(), ".m_cfg"})
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        reset_signals();
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task reset_signals();
        // TODO: Implement reset signal driving logic
        // Use m_cfg.m_vif to drive signals to reset state
        {% for signal in agent.signals if agent.role == "master" or "o" in signal.name or "_o" in signal.name %}
        // m_cfg.m_vif.{{ signal.name }} <= ...;
        {% endfor %}
    endtask
    
    virtual task drive_transaction({{ agent.name }}_seq_item item);
        // TODO: Implement transaction driving logic
        // Use m_cfg.m_vif to drive signals based on transaction
        `uvm_info("DRIVER", $sformatf("Driving transaction: %s", item.convert2string()), UVM_MEDIUM)
    endtask
    
endclass

`endif
