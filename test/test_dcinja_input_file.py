from utility.base import exec_cmd, create_temp_json_file, create_temp_template_file


def test_cmd_assign_json_file():
    fpath = create_temp_json_file({
        "name": "Foo",
    })
    cmd = """
        echo "TEST: {{ name }}" | dcinja -f %s
    """ % fpath
    assert exec_cmd(cmd) == "TEST: Foo"


def test_cmd_read_template_from_file():
    fpath = create_temp_template_file("TEST: {{ name }}")
    cmd = """
        dcinja -s %s -e name
    """ % fpath
    env = {
        'name': 'Foo',
    }
    assert exec_cmd(cmd, **env) == "TEST: Foo"
