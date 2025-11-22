#!/usr/bin/env python3

import sys
import argparse
import yaml
import jinja2

from pathlib import Path

class YAMLReader:
    
    def __init__(self, config_file: Path):
        if config_file.exists() and config_file.is_file():
            self.config_file = config_file
        else:
            print(f"Config file don't exists: {config_file}")
            sys.exit(1)
    
    def read(self):
        try:
            with open(self.config_file, 'r') as f:
                return yaml.safe_load(f)
        except yaml.YAMLError as e:
            print(f"Yaml syntax error. {e}")
            sys.exit(1)


class TemplateRenderer:
    def __init__(self, template_dir: Path):
        self.env = jinja2.Environment(
            loader=jinja2.FileSystemLoader(str(template_dir)),
            trim_blocks=True,
            lstrip_blocks=True
        )
    
    def render_agent(self, template_file: Path, agent_config: dict):
        if 'uvcs' not in template_file.parts:
            print("Template file path error:" f"{template_file}")
            sys.exit(1)

        template = self.env.get_template(str(template_file))
        return template.render(agent=agent_config)

    def render_env(self, template_file: Path, env_config: dict):
        if 'uvcs' in template_file.parts:
            print("Template file path error:" f"{template_file}")
            sys.exit(1)

        template = self.env.get_template(str(template_file))
        return template.render(env=env_config)

def get_template_directory():
    script_path = Path(__file__).parent
    template_path = script_dir / 'templates'

    if templates_path.exists() and templates_path.is_dir():
        return templates_path
    else:
        print(f"templates don't exists: {templates_path}")
        sys.exit(1)

def main():
    # Setup argument parser
    parser = argparse.ArgumentParser(description='Generate UVM code from YAML configuration')
    parser.add_argument('-c', '--cfg', type=Path, required=True, help='YAML configuration file path')
    parser.add_argument('-o', '--dest_dir', type=Path, required=True, help='Output directory (default: generated)')
    
    args = parser.parse_args()
    
    # Initialize readers
    yaml_reader = YAMLReader(args.cfg)
    template_directory = get_template_directory()
    template_renderer = TemplateRenderer(template_directory)
    
    # Read configuration
    config = yaml_reader.read()
    
    # Create output directory
    args.dest_dir.mkdir(exist_ok=True) 
    
    # Generate code for each agent
    for agent_config in config['uvcs']:
        agent_name = agent_config['name']
        
        # Create agent directory
        dest_agent_dir = args.dest_dir / 'uvcs' / agent_name
        dest_agent_dir.mkdir(parents=True, exist_ok=True)
        
        # Render all agent template with explicit agent parameter
        for file_path in (template_directory / 'uvcs').iterdir():
            content = template_renderer.render_agent(file_path.relative_to(template_directory), agent_config)
            
            # Save generated file
            dest_file = dest_agent_dir / f"{agent_name}_{file_path.name}"
            with open(dest_file, 'w') as f:
                f.write(content)
            
            print(f"Generated: {dest_file}")

    # Generate code for testbench except agent
    env_config = config['env']

    for file_path in template_directory.rglob('*'):
        if 'uvcs' in file_path.parts:
            continue
        
        elif file_path.is_dir():
            dest_sub_dir = args.dest_dir / file_path.relative_to(template_directory)
            dest_sub_dir.mkdir(exist_ok=True)

        elif file_path.is_file(): 
            content = template_renderer.render(file_path.relative_to(template_directory), env_config)

            #Save generated file
            dest_file = args.dest_dir / file_path.parent.relative_to(template_directory) / f"{env_config['name']}_{file_path.name}"
            with open(dest_file, 'w') as f:
                f.write(content)
            
            print(f"Generated: {dest_file}")

if __name__ == "__main__":
    main()
