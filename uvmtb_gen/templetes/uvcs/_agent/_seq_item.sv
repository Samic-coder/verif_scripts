`ifndef {{ agent_name.upper() }}_SEQ_ITEM_SV
`define {{ agent_name.upper() }}_SEQ_ITEM_SV

class {{ agent_name }}_seq_item extends uvm_sequence_item;
    
    // Transaction fields based on driver signals
    {% for signal in config.driver_signals %}
    rand {{ signal.type }} {{ signal.signal }};
    {% endfor %}
    
    // Constraints
    constraint signal_constraints {
        // Add transaction constraints here
    }
    
    `uvm_object_utils_begin({{ agent_name }}_seq_item)
        {% for signal in config.driver_signals %}
        `uvm_field_int({{ signal.signal }}, UVM_ALL_ON) // TODO
        {% endfor %}
    `uvm_object_utils_end
    
    function new(string name = "{{ agent_name }}_seq_item");
        super.new(name);
    endfunction

    virtual function void do_print(uvm_printer printer);
        super.do_print(printer);
        
        //printer.print_string("addr", $sformatf("0x%0h", addr));

    endfunction
    
endclass

`endif
