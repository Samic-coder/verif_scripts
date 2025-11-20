{# UVM Agent Jinja2 Template #}
{# Generate complete UVM Agent components based on YAML configuration #}

{#
  Template Variables:
  - agent_name: Agent name (e.g., "axi_master_agent")
  - config: Configuration dictionary containing valid_enable, work_mode, packages, driver_signals
#}

{## 1. Generate package import statements ##}
{% macro generate_package_imports(packages) -%}
{% for package in packages %}
import {{ package }}::*;
{% endfor %}
{%- endmacro %}

{## 2. Generate signal declarations ##}
{% macro generate_signal_declarations(signals) -%}
{% for signal in signals %}
    {{ signal.type }} {{ signal.signal }};
{% endfor %}
{%- endmacro %}

{## 3. Generate sequence_item ##}
{% set item_filename = agent_name + "_item.sv" %}
// File: {{ agent_name }}/{{ item_filename }}
`ifndef {{ agent_name.upper() }}_ITEM_SV
`define {{ agent_name.upper() }}_ITEM_SV

class {{ agent_name }}_item extends uvm_sequence_item;
    
    // Transaction fields based on driver signals
    {% for signal in config.driver_signals if "clk" not in signal.signal and "rst" not in signal.signal %}
    rand {{ signal.type }} {{ signal.signal }};
    {% endfor %}
    
    // Constraints
    constraint valid_constraints {
        // Add transaction constraints here
    }
    
    `uvm_object_utils_begin({{ agent_name }}_item)
        {% for signal in config.driver_signals if "clk" not in signal.signal and "rst" not in signal.signal %}
        `uvm_field_{{ "int" if "[" in signal.type else "enum" }}({{ signal.signal }}, UVM_ALL_ON)
        {% endfor %}
    `uvm_object_utils_end
    
    function new(string name = "{{ agent_name }}_item");
        super.new(name);
    endfunction
    
endclass

`endif
