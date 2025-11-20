`ifndef {{ agent_name.upper() }}_SEQUENCER_SV
`define {{ agent_name.upper() }}_SEQUENCER_SV

class {{ agent_name }}_sequencer extends uvm_sequencer;

    uvm_tlm_analysis_fifo #(uvm_sequence_item)  req_fifo;
    
    `uvm_component_utils({{ agent_name }}_sequencer)
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        req_fifo = new("req_fifo", this);
    endfunction


    virtual task handle_reset();
        stop_seqeunce();
        req_fifo.flush();
    endtask: handle_reset

   
    virtual task run_phase(uvm_phase phase);
        forever begin
            @(negedge m_vif.rstn);
            handle_reset();
            @(posedge m_vif.rstn);
        end
    endtask: run_phase
    
endclass

`endif
