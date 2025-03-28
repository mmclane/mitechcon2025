import argparse
import yaml
from os import listdir, path
from pathlib import Path

parser = argparse.ArgumentParser( prog="customizer", description="Customize template files using a values from yaml file")
parser.add_argument('--values-file', help="The file containing the values to customize the template files.  Defaults to customize.yaml", type=str, default='customize.yaml')
parser.add_argument('--echo', help="Don't save to file, only echo results", action=argparse.BooleanOptionalAction)
args = parser.parse_args()

# Get script path for relative file paths
script_path = path.abspath(path.dirname(__file__))

# Get list of files from the customizer-templates directory
files_to_customize = listdir(".github/customizer-templates")

# Get values from customize.yaml
values_dict = yaml.safe_load(Path(args.values_file).read_text())

customized = []
for file in files_to_customize:
    if values_dict[file]['skip']:
        print(f"Skipping {file}")
    else:
        dest_file_path = Path(f"{values_dict[file]['destination']}/{file}".strip())
        print(f"Customize {file}")
        customized.append(file)
        print("Write to file:", dest_file_path)
        print("-------------------")
        # Get template file content
        file_path = Path(f'{script_path}/customizer-templates/{file}')
        file_content = file_path.read_text()

        # Replace values in template
        for key, value in values_dict[file]['values'].items():
            file_content = file_content.replace(f"{{{{ {key} }}}}", value)

        # Either print or save the file
        if args.echo:
            print(file_content)
        else:
            dest_file_path.write_text(file_content)

# Add files to .templatesyncignore
templatesyncignore_path = Path(".templatesyncignore")
print(f"Adding customized files to .templates {templatesyncignore_path}")
print("-------------------")

templatesyncignore_content = templatesyncignore_path.read_text()
templatesyncignore_content = templatesyncignore_content.replace(f"{{{{ customized-files }}}}", '\n'.join(customized))
if args.echo:
    print(templatesyncignore_content)
else:
    templatesyncignore_path.write_text(templatesyncignore_content)
