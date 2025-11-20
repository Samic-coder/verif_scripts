{## 6. Generate monitor ##}
{% set monitor_filename = agent_name + "_monitor.sv" %}
// File: {{ agent_name }}/{{ monitor_filename }}
`ifndef {{ agent_name.upper() }}_MONITOR_SV
`define {{ agent_name.upper() }}_MONITOR_SV

class {{ agent_name }}_monitor extends uvm_monitor;

    virtual {{ agent_name }}_if vif;
    {{ agent_name }}_cfg cfg;
    uvm_analysis_port #({{ agent_name }}_item) item_collected_port;

    `uvm_component_utils({{ agent_name }}_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
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
        forever begin
            collect_transactions();
        end
    endtask

    virtual task collect_transactions();
        {{ agent_name }}_item item;
        
        // Wait for transaction start condition
        // TODO: Implement specific collection logic for {{ config.work_mode }} mode
        
        item = {{ agent_name }}_item::type_id::create("item");
        
        // Sample signals from interface
        {% for signal in config.driver_signals if "clk" not in signal.signal and "rst" not in signal.signal %}
        // item.{{ signal.signal }} = vif.{{ signal.signal }};
        {% endfor %}
        
        `uvm_info("MONITOR", $sformatf("Collected transaction: %s", item.convert2string()), UVM_HIGH)
        item_collected_port.write(item);
    endtask

endclass

`endif
