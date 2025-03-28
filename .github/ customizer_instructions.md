# Customizer.py

The customizer.py script was written (By Matt) so that we could sync files from the template repo and then customize them after the fact.

Githubs template repo functionality is limited.  When you create a repo from a template it only copies the files into the new repo.
There are often files that we need to customize afterward.  We've also setup github action jobs to sync repositories after creation.
Customizer.py will allow us to sync templates and the customize them afterward with values from customize.yaml.

## Adding new templates

- Adding a new template is easy.  Just put it in .github/customizer-templates/
- The script looks for strings that look like "{{ key }}" and replaces them with the value of the matching key in customize.yaml

## customize.yaml
This file should be fairly straight forward.

- At the root level there is a list of files, one for each file in the customizer-templates directory.  The name of the file should match the entry in customize.yaml.
- Each file has two keys.
    1. destination: this is where the script will put the customized file
    2. skip: If set to true, customizer will not create a customized version of this template.
    3. values: This is a dictionary of key: value pairs that are used to customize the templates.

## Usage
```
usage: customizer [-h] [--values-file VALUES_FILE] [--echo | --no-echo]

Customize template files using a values from yaml file

options:
  -h, --help            show this help message and exit
  --values-file VALUES_FILE
                        The file containing the values to customize the
                        template files. Defaults to customize.yaml
  --echo, --no-echo     Don't save to file, only echo results
```

NOTE: customizer.py will also update the .templatesycnignore file to add all of the files it has customized.  This keeps the template-sync job from trying to remove your customizations.
