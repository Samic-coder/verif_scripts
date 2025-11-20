{## 4. Generate agent_cfg ##}
{% set cfg_filename = agent_name + "_cfg.sv" %}
// File: {{ agent_name }}/{{ cfg_filename }}
`ifndef {{ agent_name.upper() }}_CFG_SV
`define {{ agent_name.upper() }}_CFG_SV

class {{ agent_name }}_cfg extends uvm_object;
    // Configuration parameters
    rand uvm_active_passive_enum is_active = UVM_ACTIVE;
    bit valid_enable = {% if config.valid_enable == "valid-enable" %}1'b1{% else %}1'b0{% endif %};
    string work_mode = "{{ config.work_mode }}";

    // Timing parameters
    int clock_period = 10;
    int setup_time   = 2;
    int hold_time    = 1;

    `uvm_object_utils_begin({{ agent_name }}_cfg)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
        `uvm_field_int(valid_enable, UVM_ALL_ON)
        `uvm_field_string(work_mode, UVM_ALL_ON)
        `uvm_field_int(clock_period, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "{{ agent_name }}_cfg");
        super.new(name);
    endfunction

endclass

`endif
