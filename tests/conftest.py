import pytest


@pytest.fixture(scope='function')
def example_fixture():
    return "Alex"
