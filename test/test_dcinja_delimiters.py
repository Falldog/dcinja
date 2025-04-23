from utility.base import exec_cmd


def test_cmd_square_brackets():
    cmd = """
        echo "TEST: [[ name ]]" | dcinja -x "[[ ]]" -j '{"name": "Foo"}'
    """
    assert exec_cmd(cmd) == "TEST: Foo"

def test_cmd_less_greater():
    cmd = """
        echo "TEST: << name >>" | dcinja -x "<< >>" -j '{"name": "Foo"}'
    """
    assert exec_cmd(cmd) == "TEST: Foo"

def test_cmd_comment():
    cmd = """
        echo "TEST:[# Todo #] [[ name ]]" | dcinja -c "[# #]" -x "[[ ]]" -j '{"name": "Foo"}'
    """
    assert exec_cmd(cmd) == "TEST: Foo"

def test_cmd_statement():
    cmd = """
        echo "[% set name=23 %]TEST: [[ name ]]" | dcinja -t "[% %]" -x "[[ ]]"
    """
    assert exec_cmd(cmd) == "TEST: 23"
