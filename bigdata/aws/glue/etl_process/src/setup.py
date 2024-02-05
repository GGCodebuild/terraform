from setuptools import setup

setup(
    name='etl_process',
    version='1.0',
    packages=['com', 'com/spc',
              'com/spc/process', 'com/spc/process/impl', 'com/spc/repository', 'com/spc/repository/impl',
              'com/spc/spark', 'com/spc/spark/config', 'com/spc/spark/config/impl'],

    zip_safe=False
)

#python3 setup.py bdist_egg clean --all