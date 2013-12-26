#!/usr/bin/python

import argparse
import dateutil.parser
import fcntl
import glob
import os
import re
import subprocess
import sys

SKIP_FILES = ['.rspec', '.travis.yml', 'Gemfile', 'Gemfile.lock', 'Rakefile']
SKIP_DIRECTORIES = ['spec', '.git']

def execute_subprocess(options):
    return subprocess.Popen(options, stdout=subprocess.PIPE).communicate()[0]

def get_change_from_file(file_path):
    """ This function is not used because it's too slow. It spawns
        a new git process which takes too long if you need to do it
        thousands of times
    """
    string_date = execute_subprocess(["git", "log", "-n1", "--format=%ci"])
    string_date = string_date.rstrip("\n")
    date = dateutil.parser.parse(string_date)
    return date.isoformat()

def update_file(style_path, files_to_change):
    style_path = style_path[2:] # TODO: 2: because contains ./
    file = open(style_path).read()

    if style_path.endswith('.csl'):
        updated = files_to_change[style_path]

        file = re.sub('<updated>.*</updated>', '<updated>%s</updated>' % updated, file)

    return file

def write_readme_md():
    text = """CSL Style distribution
======================

This repository is a copy of [github.com/citation-style-language/styles](https://github.com/citation-style-language/styles), refreshed twice a day, with the <updated> tag changed up to the last git change for a certain file.

Licensing
---------
Please refer to [github.com/citation-style-language/styles](https://github.com/citation-style-language/styles)
"""

    file = open("README.md", "w")
    file.write(text)
    file.close()

def write_new_style(path, updated_style):
    file = open(os.path.join(DISTRIBUTION_STYLES_DIRECTORY, path), 'w')

    file.write(updated_style)

def original_last_commit():
    """ Returns de last commit of the ORIGINAL_STYLES_DIRECTORY. """
    last_dir = os.getcwd()

    os.chdir(ORIGINAL_STYLES_DIRECTORY)

    last_commit = execute_subprocess(["git", "log", "-n1", "--format=%H"])

    os.chdir(last_dir)

    return last_commit

def copy_and_update_styles(files_to_change):
    for root, subDirectories, files in os.walk("."):
        for file in files:
            if file not in SKIP_FILES and root[2:].split('/')[0]  not in SKIP_DIRECTORIES:
                path = os.path.join(root, file)
                updated_file = update_file(path, files_to_change)

                write_new_style(path, updated_file)

def count_styles_git_index(directory):
    count = 0
    last_dir = os.getcwd()

    os.chdir(directory)

    files = execute_subprocess(["git", "ls-files"])

    for file in files.split("\n"):
        if file.endswith('.csl'):
            count += 1

    os.chdir(last_dir)

    return count

def delete_styles():
    styles = glob.glob(DISTRIBUTION_STYLES_DIRECTORY + "/*.csl")
    dependent_styles = glob.glob(DISTRIBUTION_STYLES_DIRECTORY + "/dependent/*.csl")

    for style in styles + dependent_styles:
        os.unlink(style)

def prepare_files_to_change():
    last_dir = os.getcwd()

    files_to_change = {}

    os.chdir(ORIGINAL_STYLES_DIRECTORY)

    log = execute_subprocess(["git", "log", "--pretty=Date:%ai", "--name-only"])

    last_date = ""
    for line in log.split("\n"):
        if line.startswith("Date:"):
            last_date = dateutil.parser.parse(line[len('Date:'):]).isoformat()
        elif line.endswith('.csl'):
            if files_to_change.has_key(line):
                if last_date > files_to_change[line]:
                    files_to_change[line] = last_date
            else:
                files_to_change[line] = last_date

    os.chdir(last_dir)

    return files_to_change
    
def push_changes(dry_run):
    os.chdir(DISTRIBUTION_STYLES_DIRECTORY)

    write_readme_md()

    os.system("git add -A")

    os.system("git commit -a -m 'Synced up to https://github.com/citation-style-language/styles/commit/%s'" % (original_last_commit()))

    styles_distribution_directory_count = count_styles_git_index(DISTRIBUTION_STYLES_DIRECTORY)
    styles_directory_count = count_styles_git_index(ORIGINAL_STYLES_DIRECTORY)

    if styles_distribution_directory_count == styles_directory_count and \
                styles_distribution_directory_count > 6000:
        print "Success"
	if not dry_run:
            os.system("git push")
    else:
        sys.stderr.write("styles_distribution_directory: %d\n" % (styles_distribution_directory_count))
        sys.stderr.write("styles_directory: %d\n" % (styles_directory_count))

def main(dry_run, commit):
    lockfile = open("/tmp/csls.lock", "w")
    fcntl.flock(lockfile, fcntl.LOCK_EX)

    os.chdir(ORIGINAL_STYLES_DIRECTORY)
    execute_subprocess(["git","pull"])
    execute_subprocess(["git", "checkout", commit])

    delete_styles()

    dependents_directory = os.path.join(DISTRIBUTION_STYLES_DIRECTORY, "dependent")

    if not os.path.exists(dependents_directory):
        os.mkdir(dependents_directory)

    files_to_change = prepare_files_to_change()

    copy_and_update_styles(files_to_change)

    push_changes(dry_run)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Prepares and pushes style repository to be distributed.')
    parser.add_argument('--dry-run', action='store_true', help='Do everything except git push (default: %(default)s).', default=False)
    parser.add_argument('--commit', default='HEAD', help='Which commit to checkout from --original_styles_directory option (default: %(default)s)')
    parser.add_argument('--original-styles-directory', required=True, help='Directory with a git checkout of https://github.com/citation-style-language/styles')
    parser.add_argument('--distribution-styles-directory', required=True, help='Directory with a git checkout of the destination directory')
    args = vars(parser.parse_args())

    ORIGINAL_STYLES_DIRECTORY = args['original_styles_directory']
    DISTRIBUTION_STYLES_DIRECTORY = args['distribution_styles_directory']

    main(args['dry_run'], args['commit'])
