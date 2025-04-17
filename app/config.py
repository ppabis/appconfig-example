import requests, yaml
def get_value(key, default):
    """
    :param key: the key to retrieve from the config. Can be in dot notation to retrieve a nested value.
    :param default: the default value to return if the key is not found
    :return: the retrieved or default value
    """
    c = get_config()
    if not isinstance(c, dict):
        return default
    
    keys = key.split('.')
    current = c
    
    for k in keys:
        if not isinstance(current, dict):
            return default
        if k not in current:
            return default
        current = current[k]
    
    return current

def get_config():
    req = requests.get("http://localhost:2772/applications/appconfig-demo/environments/live/configurations/main")
    if req.status_code >= 200 and req.status_code < 300:
        if req.headers.get("Content-Type") == "application/yaml":
            return yaml.safe_load(req.text)
        elif req.headers.get("Content-Type") == "application/json":
            return req.json()
        else:
            return req.text
    else:
        return f"None, Status code: {req.status_code} {req.text}"

def is_feature_enabled(key, default):
    ff = get_feature_flag(key, default)    
    if isinstance(ff, dict) and 'enabled' in ff and ff['enabled'] == True:
        return True
    return default

def get_feature_attribute(key, attribute, default):
    ff = get_feature_flag(key, default)
    if isinstance(ff, dict) and attribute in ff:
        return ff[attribute]
    return default

def get_feature_flag(key, default):
    req = requests.get(f"http://localhost:2772/applications/appconfig-demo/environments/live/configurations/featureflags?flag={key}")
    if req.status_code >= 200 and req.status_code < 300:
        return req.json()
    else:
        return default
