
{## 7. Generate sequencer ##}
{% set sequencer_filename = agent_name + "_sequencer.sv" %}
// File: {{ agent_name }}/{{ sequencer_filename }}
`ifndef {{ agent_name.upper() }}_SEQUENCER_SV
`define {{ agent_name.upper() }}_SEQUENCER_SV

class {{ agent_name }}_sequencer extends uvm_sequencer #({{ agent_name }}_item);
    
    `uvm_component_utils({{ agent_name }}_sequencer)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
endclass

`endif
