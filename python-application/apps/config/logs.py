import logging

logging_config = dict(
    version=1,
    formatters={
        "f": {'format': '%(asctime)s %(levelname)-8s %(message)s'}
    },
    handlers={
        "h": {
            'class': 'logging.StreamHandler',
            'formatter': 'f',
            'level': logging.INFO
        }
    },
    root={
        'handlers': ['h'],
        'level': logging.INFO
    },
)