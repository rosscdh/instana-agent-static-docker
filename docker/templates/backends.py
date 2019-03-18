import os
import yaml
from jproperties import Properties

OUTPUT = os.getenv('OUTPUT', 'backends')
BACKENDS = os.getenv('BACKENDS', 'backends.yml')

backends = yaml.load(open(BACKENDS, 'r'),
                     Loader=yaml.SafeLoader)

for index, backend in enumerate(backends.get('backends', [])):
    filename = 'com.instana.agent.main.sender.Backend-{}.cfg'.format(index + 1)
    props = Properties()
    for key, value in backend.items():
        if value:
            props[key] = value.decode('utf-8') if type(value) in [str] else str(value)

    with open(os.path.join(OUTPUT, filename), 'w') as f:
        props.store(f, encoding="utf-8")