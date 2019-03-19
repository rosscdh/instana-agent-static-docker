import os
import yaml
from jproperties import Properties

INSTANA_AGENT_KEY = os.getenv('INSTANA_AGENT_KEY')
assert INSTANA_AGENT_KEY, 'You must specify an INSTANA_AGENT_KEY env variable'

BACKENDS = os.getenv('BACKENDS')
OUTPUT = os.getenv('OUTPUT')

backends = yaml.load(open(BACKENDS, 'r'),
                     Loader=yaml.SafeLoader)

for index, backend in enumerate(backends.get('backends', [])):
    filename = 'com.instana.agent.main.sender.Backend-{}.cfg'.format(index + 1)
    props = Properties()
    props['key'] = str(INSTANA_AGENT_KEY)
    for key, value in backend.items():
        if value:
            props[key] = value.decode('utf-8') if type(value) in [str] else str(value)

    with open(os.path.join(OUTPUT, filename), 'w') as f:
        props.store(f, encoding="utf-8")