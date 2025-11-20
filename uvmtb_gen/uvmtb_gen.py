#!/usr/bin/env python3
"""
UVM Code Generator
Automatically generates UVM agent components based on YAML configuration and Jinja2 templates
"""

import os
import sys
import yaml
import jinja2
import argparse
import logging
from pathlib import Path
from typing import Dict, Any, List

class UVMCodeGenerator:
    """UVM Code Generator Class"""
    
    def __init__(self, debug: bool = False):
        """Initialize the code generator"""
        self.debug = debug
        self.setup_logging(debug)
        
        # Setup Jinja2 environment
        self.template_env = jinja2.Environment(
            loader=jinja2.FileSystemLoader('.'),
            trim_blocks=True,
            lstrip_blocks=True,
            keep_trailing_newline=True
        )
        
    def setup_logging(self, debug: bool):
        """Setup logging configuration"""
        log_level = logging.DEBUG if debug else logging.INFO
        logging.basicConfig(
            level=log_level,
            format='%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        self.logger = logging.getLogger(__name__)
        
    def load_config(self, config_file: str) -> Dict[str, Any]:
        """Load YAML configuration file"""
        self.logger.info(f"Loading configuration from: {config_file}")
        
        try:
            with open(config_file, 'r') as file:
                config = yaml.safe_load(file)
                
            if not config:
                raise ValueError("Configuration file is empty")
                
            self.logger.debug(f"Configuration loaded successfully: {config}")
            return config
            
        except FileNotFoundError:
            self.logger.error(f"Configuration file not found: {config_file}")
            sys.exit(1)
        except yaml.YAMLError as e:
            self.logger.error(f"YAML parsing error: {e}")
            sys.exit(1)
        except Exception as e:
            self.logger.error(f"Error loading configuration: {e}")
            sys.exit(1)
    
    def load_template(self, template_file: str) -> jinja2.Template:
        """Load Jinja2 template file"""
        self.logger.info(f"Loading template: {template_file}")
        
        try:
            template = self.template_env.get_template(template_file)
            self.logger.debug(f"Template loaded successfully: {template_file}")
            return template
            
        except jinja2.TemplateNotFound:
            self.logger.error(f"Template file not found: {template_file}")
            sys.exit(1)
        except Exception as e:
            self.logger.error(f"Error loading template: {e}")
            sys.exit(1)
    
    def create_agent_directory(self, agent_name: str, target_dir: str) -> str:
        """Create agent directory structure"""
        agent_dir = os.path.join(target_dir, agent_name)
        
        try:
            os.makedirs(agent_dir, exist_ok=True)
            self.logger.debug(f"Created agent directory: {agent_dir}")
            return agent_dir
            
        except Exception as e:
            self.logger.error(f"Error creating directory {agent_dir}: {e}")
            sys.exit(1)
    
    def generate_agent_components(self, agent_config: Dict[str, Any], template: jinja2.Template, target_dir: str):
        """Generate all components for a single agent"""
        agent_name = agent_config['agent_name']
        config = agent_config['config']
        
        self.logger.info(f"Generating components for agent: {agent_name}")
        self.logger.debug(f"Agent configuration: {config}")
        
        # Create agent directory
        agent_dir = self.create_agent_directory(agent_name, target_dir)
        
        # List of components to generate
        components = [
            f"{agent_name}_item.sv",
            f"{agent_name}_cfg.sv", 
            f"{agent_name}_driver.sv",
            f"{agent_name}_monitor.sv",
            f"{agent_name}_sequencer.sv",
            f"{agent_name}.sv",
            f"{agent_name}_if.sv"
        ]
        
        # Generate each component
        for component_file in components:
            self.generate_component(agent_name, config, template, agent_dir, component_file)
    
    def generate_component(self, agent_name: str, config: Dict[str, Any], template: jinja2.Template, 
                          agent_dir: str, component_file: str):
        """Generate a single component file"""
        output_file = os.path.join(agent_dir, component_file)
        
        try:
            # Render template with agent data
            rendered_content = template.render(
                agent_name=agent_name,
                config=config
            )
            
            # Extract the specific component from rendered content
            component_content = self.extract_component_from_rendered(rendered_content, component_file)
            
            if component_content:
                # Write to file
                with open(output_file, 'w') as file:
                    file.write(component_content)
                
                self.logger.info(f"Generated: {output_file}")
                self.logger.debug(f"Content preview:\n{component_content[:200]}...")
            else:
                self.logger.warning(f"Could not extract component {component_file} from template")
                
        except Exception as e:
            self.logger.error(f"Error generating {component_file}: {e}")
    
    def extract_component_from_rendered(self, rendered_content: str, component_file: str) -> str:
        """Extract specific component content from rendered template"""
        lines = rendered_content.split('\n')
        component_lines = []
        in_component = False
        component_identifier = f"// File: {component_file.split('/')[-1]}"
        
        for line in lines:
            if component_identifier in line:
                in_component = True
                component_lines = [line]  # Start with the identifier line
                continue
                
            if in_component:
                if line.strip().startswith('// File:') and line != component_identifier:
                    # Reached next component, stop collecting
                    break
                component_lines.append(line)
        
        return '\n'.join(component_lines) if component_lines else None
    
    def generate_global_config(self, global_config: Dict[str, Any], target_dir: str):
        """Generate global configuration file"""
        global_config_file = os.path.join(target_dir, "global_config.sv")
        
        try:
            with open(global_config_file, 'w') as file:
                file.write("// Global Configuration\n")
                file.write("// Auto-generated from YAML configuration\n\n")
                file.write("package global_config_pkg;\n\n")
                
                for key, value in global_config.items():
                    if isinstance(value, str):
                        file.write(f'  string {key} = "{value}";\n')
                    else:
                        file.write(f'  int {key} = {value};\n')
                
                file.write("\nendpackage\n")
            
            self.logger.info(f"Generated global config: {global_config_file}")
            
        except Exception as e:
            self.logger.error(f"Error generating global config: {e}")
    
    def generate_all_agents(self, config: Dict[str, Any], template_file: str, target_dir: str):
        """Generate all agents from configuration"""
        self.logger.info("Starting UVM code generation...")
        
        # Load template
        template = self.load_template(template_file)
        
        # Create target directory
        os.makedirs(target_dir, exist_ok=True)
        self.logger.info(f"Target directory: {target_dir}")
        
        # Generate global configuration
        if 'global_config' in config.get('testbench_config', {}):
            self.generate_global_config(config['testbench_config']['global_config'], target_dir)
        
        # Generate each agent
        agents = config.get('testbench_config', {}).get('agents', [])
        
        if not agents:
            self.logger.warning("No agents found in configuration")
            return
        
        self.logger.info(f"Found {len(agents)} agent(s) to generate")
        
        for agent_config in agents:
            self.generate_agent_components(agent_config, template, target_dir)
        
        self.logger.info("UVM code generation completed successfully!")
    
    def print_summary(self, config: Dict[str, Any], target_dir: str):
        """Print generation summary"""
        agents = config.get('testbench_config', {}).get('agents', [])
        
        print("\n" + "="*50)
        print("UVM CODE GENERATION SUMMARY")
        print("="*50)
        print(f"Target Directory: {target_dir}")
        print(f"Agents Generated: {len(agents)}")
        
        for agent in agents:
            agent_name = agent['agent_name']
            work_mode = agent['config']['work_mode']
            valid_enable = agent['config']['valid_enable']
            num_signals = len(agent['config']['driver_signals'])
            
            print(f"  - {agent_name}:")
            print(f"      Mode: {work_mode}")
            print(f"      Protocol: {valid_enable}")
            print(f"      Signals: {num_signals}")
            
            if self.debug:
                packages = agent['config']['packages']
                print(f"      Packages: {', '.join(packages)}")
        
        print("="*50)

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='UVM Code Generator')
    parser.add_argument('-c', '--config', required=True, 
                       help='YAML configuration file path')
    parser.add_argument('-t', '--template', default='uvm_agent_template.j2',
                       help='Jinja2 template file path (default: uvm_agent_template.j2)')
    parser.add_argument('-o', '--output', default='./uvm_output',
                       help='Target output directory (default: ./uvm_output)')
    parser.add_argument('-d', '--debug', action='store_true',
                       help='Enable debug output')
    
    args = parser.parse_args()
    
    # Initialize code generator
    generator = UVMCodeGenerator(debug=args.debug)
    
    # Load configuration
    config = generator.load_config(args.config)
    
    # Generate all agents
    generator.generate_all_agents(config, args.template, args.output)
    
    # Print summary
    generator.print_summary(config, args.output)

if __name__ == "__main__":
    main()
