from utility.base import exec_cmd, create_temp_template_file, create_temp_file_path


def test_cmd_write_output_to_file():
    output_path = create_temp_file_path()
    input_path = create_temp_template_file("TEST: {{ name }}")
    cmd = """
        dcinja \
        -s %s \
        -d %s \
        -e name
    """ % (input_path, output_path)
    env = {
        'name': 'Foo',
    }
    assert exec_cmd(cmd, **env) == ""
    with open(output_path, 'rb') as f:
        content = f.read().decode('utf-8')
        assert content == "TEST: Foo"
