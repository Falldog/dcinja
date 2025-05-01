from utility.base import exec_cmd


def test_print_help():
    cmd = """
        dcinja -h
    """
    output = exec_cmd(cmd)
    assert '--help' in output


def test_cmd_assign_json():
    cmd = """
        echo "TEST: {{ name }}" \
        | \
        dcinja \
        -j '{"name": "Foo"}'
    """
    assert exec_cmd(cmd) == "TEST: Foo"

