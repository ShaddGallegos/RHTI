
# The system UUID, as captured by Ansible.
SYSTEM_UUID = '{% if system_uuid is skipped %}{{ ansible_product_uuid.lower() }}{% else %}{{ system_uuid.stdout.strip() }}{% endif %}'
