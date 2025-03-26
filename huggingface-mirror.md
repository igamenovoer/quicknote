## How to set huggingface url for diffuers
```python
import os

# download models if needed
os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
os.environ['HF_HUB_OFFLINE'] = '0'

# if you want to point hf cache to a local storage, use this
# os.environ['HF_HOME']='/path/to/hf-cache'
```
