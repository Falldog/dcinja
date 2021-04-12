import os
import json
import tempfile
import subprocess


def exec_cmd(cmd, **env):
    _env = os.environ.copy()
    _env.update(env)
    output = subprocess.check_output(cmd.strip(), shell=True, env=_env)
    output = output.decode('utf-8')
    if output and output[-1] == '\n':
        return output[:-1]  # remove the EOF new line from default dcinja behavior
    return output


def create_temp_json_file(json_obj):
    file_path = tempfile.mkstemp(prefix='dcinja_')[1]
    with open(file_path, 'wb') as f:
        content = json.dumps(json_obj)
        f.write(content.encode('utf-8'))
    return file_path


def create_temp_template_file(content):
    file_path = tempfile.mkstemp(prefix='dcinja_')[1]
    with open(file_path, 'wb') as f:
        f.write(content.encode('utf-8'))
    return file_path


def create_temp_file_path():
    return tempfile.mkstemp(prefix='dcinja_')[1]

