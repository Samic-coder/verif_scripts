// UVM Sequence Item Template
// Auto-generated from YAML configuration

`ifndef {{ agent.name | upper }}_SEQ_ITEM_SV
`define {{ agent.name | upper }}_SEQ_ITEM_SV

class {{ agent.name }}_seq_item extends uvm_sequence_item;
    
    // Transaction fields based on signal definitions
    {% for signal in agent.signals %}
    rand {{ signal.type }} {{ signal.name }};
    {% endfor %}
    
    // Constraints - TODO: Add specific constraints
    constraint valid_constraints {
        // TODO: Add constraints for {{ agent.name }} transaction
    }
    
    `uvm_object_utils_begin({{ agent.name }}_seq_item)
        {% for signal in agent.signals %}
        // TODO: Manually adjust field macro based on actual data type
        `uvm_field_int({{ signal.name }}, UVM_ALL_ON)
        {% endfor %}
    `uvm_object_utils_end
    
    function new(string name = "{{ agent.name }}_seq_item");
        super.new(name);
    endfunction
    
    // TODO: Uncomment and customize do_print() if any signal is struct type
    /*
    virtual function void do_print(uvm_printer printer);
        super.do_print(printer);
        {% for signal in agent.signals %}
        // Example for struct type signal:
        // printer.print_string("{{ signal.name }}", $sformatf("%p", {{ signal.name }}));
        {% endfor %}
    endfunction
    */
    
endclass

`endif
