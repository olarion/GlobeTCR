# config.py

from pathlib import Path

# Default GLBDM number
# glbdm_no = '321'
# glbdm_no = '315'
# glbdm_no = '284'

# Base directory for source CSVs
base_source_dir = Path(__file__).resolve().parent.parent / 'source'

# Combined mapping: which 3rd-party sources are needed per GLBDM,
# and their respective folder paths
site_data = {
    '315': {
        'aaa':   {'need': True,  'path': str(base_source_dir / 'aaa')},
        'altip': {'need': False, 'path': str(base_source_dir / 'altip')},
        'bss':   {'need': False, 'path': str(base_source_dir / 'bss')},
        'lfdno': {'need': False, 'path': str(base_source_dir / 'lfdno')},
        'nms':   {'need': False, 'path': str(base_source_dir / 'nms')},
    },
    '321': {
        'aaa':   {'need': True,  'path': str(base_source_dir / 'aaa')},
        'altip': {'need': False, 'path': str(base_source_dir / 'altip')},
        'bss':   {'need': True,  'path': str(base_source_dir / 'bss')},
        'lfdno': {'need': False, 'path': str(base_source_dir / 'lfdno')},
        'nms':   {'need': False, 'path': str(base_source_dir / 'nms')},
    },
    '283': {
        'aaa':   {'need': False,  'path': str(base_source_dir / 'aaa')},
        'altip': {'need': False, 'path': str(base_source_dir / 'altip')},
        'bss':   {'need': False, 'path': str(base_source_dir / 'bss')},
        'lfdno': {'need': False, 'path': str(base_source_dir / 'lfdno')},
        'nms': {'need': False, 'path': str(base_source_dir / 'nms')},
    },
    '284': {
        'aaa':   {'need': False,  'path': str(base_source_dir / 'aaa')},
        'altip': {'need': False, 'path': str(base_source_dir / 'altip')},
        'bss':   {'need': False, 'path': str(base_source_dir / 'bss')},
        'lfdno': {'need': False, 'path': str(base_source_dir / 'lfdno')},
        'nms_284': {'need': True, 'path': str(base_source_dir / 'nms_284')},
    },
}
# end
