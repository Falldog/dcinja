from utility.base import exec_cmd, create_temp_json_file


def test_cmd_force_system_envs():
    cmd = """
        echo "TEST: {{ name }}" | dcinja -e name=Foo --force-system-envs
    """
    env = {
        'name': 'BAR',
    }
    assert exec_cmd(cmd, **env) == "TEST: BAR"


def test_cmd_not_force_system_envs():
    cmd = """
        echo "TEST: {{ name }}" | dcinja -e name=Foo
    """
    env = {
        'name': 'BAR',
    }
    assert exec_cmd(cmd, **env) == "TEST: Foo"


def test_cmd_read_json_file_as_default():
    fpath = create_temp_json_file({
        "name": "Foo",
    })

    # use json value
    cmd = """
        echo "TEST: {{ name }}" | dcinja -f %s
    """ % fpath
    env = {
        'name': 'BAR',
    }
    assert exec_cmd(cmd, **env) == "TEST: Foo"

    # use system env value
    cmd = """
        echo "TEST: {{ name }}" | dcinja -f %s --force-system-envs
    """ % fpath
    env = {
        'name': 'BAR',
    }
    assert exec_cmd(cmd, **env) == "TEST: BAR"
