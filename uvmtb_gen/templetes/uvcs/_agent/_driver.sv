`ifndef {{ agent_name.upper() }}_DRIVER_SV
`define {{ agent_name.upper() }}_DRIVER_SV

class {{ agent_name }}_driver extends uvm_driver;
    
    virtual {{ agent_name }}_if vif;
    {{ agent_name }}_cfg cfg;
    
    `uvm_component_utils({{ agent_name }}_driver)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual {{ agent_name }}_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"})
        end
        if(!uvm_config_db#({{ agent_name }}_cfg)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal("NOCFG", {"Config must be set for: ", get_full_name(), ".cfg"})
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
        // Reset all driver signals
        {% for signal in config.driver_signals if config.work_mode == "master" or "o" in signal.signal or "_o" in signal.signal %}
        vif.{{ signal.signal }} <= {% if "rst" in signal.signal %}1'b1{% else %}{% if "[" in signal.type %}'b0{% else %}1'b0{% endif %}{% endif %};
        {% endfor %}
    endtask
    
    virtual task drive_transaction({{ agent_name }}_item item);
        // Implement drive logic based on work_mode and valid_enable
        `uvm_info("DRIVER", $sformatf("Driving transaction: %s", item.convert2string()), UVM_MEDIUM)
        
        // TODO: Add specific drive logic for {{ config.work_mode }} mode
        // Valid-enable protocol: {{ config.valid_enable }}
        
    endtask
    
endclass

`endif
