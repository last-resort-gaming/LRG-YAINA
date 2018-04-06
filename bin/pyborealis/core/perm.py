
class Permission(object):
    def __init__(self, provider_id, provider_name, permission):
        self.provider_id = provider_id
        self.provider = provider_name
        self.permission = permission

    def __str__(self):
        return self.permission