// UVM Agent Configuration Template
// Auto-generated from YAML configuration

`ifndef {{ agent.name | upper }}_CFG_SV
`define {{ agent.name | upper }}_CFG_SV

class {{ agent.name }}_cfg extends uvm_object;
    
    // Virtual interface
    virtual {{ agent.name }}_if m_vif;
    
    // Agent working mode
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    
    `uvm_object_utils_begin({{ agent.name }}_cfg)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "{{ agent.name }}_cfg");
        super.new(name);
    endfunction
    
endclass

`endif
