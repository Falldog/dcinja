from utility.base import exec_cmd


def test_cmd_assign_env():
    cmd = """
        echo "TEST: {{ name }}" | dcinja -e name=Foo
    """
    assert exec_cmd(cmd) == "TEST: Foo"


def test_cmd_assign_system_env():
    cmd = """
        echo "TEST: {{ name }}" | dcinja -e name
    """
    env = {
        'name': 'Foo',
    }
    assert exec_cmd(cmd, **env) == "TEST: Foo"


def test_cmd_assign_env_and_system_env_1():
    cmd = """
        echo "TEST: {{ name }}" | dcinja -e name -e name=BAR
    """
    env = {
        'name': 'Foo',
    }
    assert exec_cmd(cmd, **env) == "TEST: BAR"


def test_cmd_assign_env_and_system_env_2():
    cmd = """
        echo "TEST: {{ name }}" | dcinja -e name=BAR -e name
    """
    env = {
        'name': 'Foo',
    }
    assert exec_cmd(cmd, **env) == "TEST: Foo"


def test_cmd_assign_env_and_empty_system_env():
    cmd = """
        echo "TEST: {{ name }}" | dcinja -e name=BAR -e name
    """
    env = {
    }
    assert exec_cmd(cmd, **env) == "TEST: BAR"

